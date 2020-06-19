#!/bin/bash

# Stops the script, if an error occurred.
set -e

DIGITALOCEAN_TOKEN=$DIGITALOCEAN_TOKEN
DOMAIN_NAME=$DOMAIN_NAME
LETSENCRYPT_EMAIL=$LETSENCRYPT_EMAIL

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
  |& tee /tmp/certbot.status

if ! grep -q "Cert not yet due for renewal" /tmp/certbot.status; then

  CERTIFICATES=$(curl -X GET "https://api.digitalocean.com/v2/certificates" \
    -H "Authorization: Bearer $DIGITALOCEAN_TOKEN")

  CERTIFICATE_ID=$(echo $CERTIFICATES | jq -r '.certificates[] | select(.name == "'"$DOMAIN_NAME"'") | .id')

  if [ -n "${CERTIFICATE_ID}" ]; then
    curl -X DELETE "https://api.digitalocean.com/v2/certificates/$CERTIFICATE_ID" \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $DIGITALOCEAN_TOKEN"
  fi

  PRIVATE_KEY=$(jq -aRs . < /etc/letsencrypt/live/$DOMAIN_NAME/privkey.pem)
  LEAF_CERT=$(jq -aRs . < /etc/letsencrypt/live/$DOMAIN_NAME/cert.pem)
  CERT_CHAIN=$(jq -aRs . < /etc/letsencrypt/live/$DOMAIN_NAME/fullchain.pem)

  cat << EOF > /tmp/cert.json
  {
    "name": "$DOMAIN_NAME",
    "type": "custom",
    "private_key": $PRIVATE_KEY,
    "leaf_certificate": $LEAF_CERT,
    "certificate_chain": $CERT_CHAIN
  }
EOF

  curl -X POST "https://api.digitalocean.com/v2/certificates" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
    -d @/tmp/cert.json

  curl -X GET "https://api.digitalocean.com/v2/certificates" \
    -H "Authorization: Bearer $DIGITALOCEAN_TOKEN"

fi
