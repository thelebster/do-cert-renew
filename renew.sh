#!/bin/bash

# Stops the script, if an error occurred.
set -e

DIGITALOCEAN_TOKEN=$DIGITALOCEAN_TOKEN
DIGITALOCEAN_CDN_ORIGIN=$DIGITALOCEAN_CDN_ORIGIN
DOMAIN_NAME=$DOMAIN_NAME
LETSENCRYPT_EMAIL=$LETSENCRYPT_EMAIL
UUID_REGEXP='[0-9a-fA-F]{8}\\-[0-9a-fA-F]{4}\\-[0-9a-fA-F]{4}\\-[0-9a-fA-F]{4}\\-[0-9a-fA-F]{12}'
CERTBOT_STATUS_OUTPUT=/tmp/certbot.status
CERTBOT_ARGS=$CERTBOT_ARGS

# Clean the certbot status output before run again.
rm -f $CERTBOT_STATUS_OUTPUT

certbot certonly \
  --manual \
  -n \
  --agree-tos \
  --preferred-challenges=dns \
  --manual-auth-hook /letsencrypt-dns-authenticator.sh \
  --manual-cleanup-hook /letsencrypt-dns-cleanup.sh \
  --manual-public-ip-logging-ok \
  -d $DOMAIN_NAME \
  -m $LETSENCRYPT_EMAIL \
  ${CERTBOT_ARGS} \
  |& tee $CERTBOT_STATUS_OUTPUT

# Check if certbot response is not empty.
if [ ! -f $CERTBOT_STATUS_OUTPUT ] || [ ! -s $CERTBOT_STATUS_OUTPUT ]; then
  echo "Certbot response is empty"
  exit 1
fi

if grep -qi "An unexpected error occurred" $CERTBOT_STATUS_OUTPUT; then
  exit 1
fi

if grep -qi "Cert not yet due for renewal" $CERTBOT_STATUS_OUTPUT; then
  exit 0
fi

PRIVATE_KEY=$(jq -aRs . < /etc/letsencrypt/live/$DOMAIN_NAME/privkey.pem)
LEAF_CERT=$(jq -aRs . < /etc/letsencrypt/live/$DOMAIN_NAME/cert.pem)
CERT_CHAIN=$(jq -aRs . < /etc/letsencrypt/live/$DOMAIN_NAME/fullchain.pem)
CERT_NAME="$(uuidgen).$DOMAIN_NAME"

cat << EOF > /tmp/cert.json
{
  "name": "$CERT_NAME",
  "type": "custom",
  "private_key": $PRIVATE_KEY,
  "leaf_certificate": $LEAF_CERT,
  "certificate_chain": $CERT_CHAIN
}
EOF

CERTIFICATE=$(curl -X POST "https://api.digitalocean.com/v2/certificates" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
  -d @/tmp/cert.json)

if [ -n "${CERTIFICATE}" ]; then
  CERTIFICATE_ID=$(echo $CERTIFICATE | jq -r '.certificate | .id')
  if [ -n "${CERTIFICATE_ID}" ]; then
    # Get an existing CDN endpoint.
    CDN_ENDPOINTS=$(curl -X GET "https://api.digitalocean.com/v2/cdn/endpoints" \
      -H "Authorization: Bearer $DIGITALOCEAN_TOKEN")

    CDN_ENDPOINT_ID=$(echo $CDN_ENDPOINTS | jq -r '.endpoints[] | select(.custom_domain == "'"$DOMAIN_NAME"'") | .id')
    if [ -n "${CDN_ENDPOINT_ID}" ]; then
      echo "Updating an existing CDN endpoint"
      RESPONSE=$(curl -X PUT "https://api.digitalocean.com/v2/cdn/endpoints/$CDN_ENDPOINT_ID" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
        -d '{"certificate_id": "'"$CERTIFICATE_ID"'", "custom_domain": "'"$DOMAIN_NAME"'"}')

      echo $RESPONSE

      echo "Removing old certificates"
      CERTIFICATES=$(curl -X GET "https://api.digitalocean.com/v2/certificates" \
        -H "Authorization: Bearer $DIGITALOCEAN_TOKEN")

      if [ -n "${CERTIFICATES}" ]; then
        CERTIFICATES=$(echo $CERTIFICATES | jq -r '.certificates[] | select(.name | test("'"$UUID_REGEXP.$DOMAIN_NAME"'")) | select(.id != "'"$CERTIFICATE_ID"'") | .id')
        for CERT_ID in $CERTIFICATES
        do
          curl -X DELETE "https://api.digitalocean.com/v2/certificates/$CERT_ID" \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $DIGITALOCEAN_TOKEN"
        done
      fi
    else
      echo "Creating new CDN endpoint"
      RESPONSE=$(curl -X POST "https://api.digitalocean.com/v2/cdn/endpoints" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
        -d '{"origin": "'"$DIGITALOCEAN_CDN_ORIGIN"'", "certificate_id": "'"$CERTIFICATE_ID"'", "custom_domain": "'"$DOMAIN_NAME"'"}')

      echo $RESPONSE
    fi
  fi
fi
