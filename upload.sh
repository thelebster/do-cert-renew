#!/bin/bash

# Stops the script, if an error occurred.
set -e

DIGITALOCEAN_TOKEN=$DIGITALOCEAN_TOKEN
LETSENCRYPT_EMAIL=$LETSENCRYPT_EMAIL
UUID_REGEXP='[0-9a-fA-F]{8}\\-[0-9a-fA-F]{4}\\-[0-9a-fA-F]{4}\\-[0-9a-fA-F]{4}\\-[0-9a-fA-F]{12}'
CERTBOT_ARGS=$CERTBOT_ARGS

# Usage: upload_cert example.ams3.digitaloceanspaces.com cdn.example.com
upload_cert() {
  local DIGITALOCEAN_CDN_ORIGIN=$1
  local CUSTOM_DOMAIN_NAME=$2
  local CERT_RENEWED=1 # Suppose that cert should be renewed.
  echo "Upload certificate for custom domain: ${CUSTOM_DOMAIN_NAME}"

  # If cert has been renewed, upload to DigitalOcean.
  if [ $CERT_RENEWED -ne 0 ]; then
    PRIVATE_KEY=$(jq -aRs . < /etc/letsencrypt/live/$CUSTOM_DOMAIN_NAME/privkey.pem)
    LEAF_CERT=$(jq -aRs . < /etc/letsencrypt/live/$CUSTOM_DOMAIN_NAME/cert.pem)
    CERT_CHAIN=$(sed ':a;N;$!ba;s/\n\n/\n/g' < /etc/letsencrypt/live/$CUSTOM_DOMAIN_NAME/fullchain.pem | jq -aRs .)
    CERT_NAME="$(uuidgen).$CUSTOM_DOMAIN_NAME"
    CERT_REQUEST_DATA_FILE_NAME=/tmp/certbot/$CUSTOM_DOMAIN_NAME.cert.json

    cat << EOF > $CERT_REQUEST_DATA_FILE_NAME
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
      -d @$CERT_REQUEST_DATA_FILE_NAME)

    echo $CERTIFICATE

    if [ -n "${CERTIFICATE}" ]; then
      CERTIFICATE_ID=$(echo $CERTIFICATE | jq -r '.certificate | .id')
      if [ -n "${CERTIFICATE_ID}" ]; then
        # Get an existing CDN endpoint.
        CDN_ENDPOINTS=$(curl -X GET "https://api.digitalocean.com/v2/cdn/endpoints" \
          -H "Authorization: Bearer $DIGITALOCEAN_TOKEN")

        echo $CDN_ENDPOINTS

        CDN_ENDPOINT_ID=$(echo $CDN_ENDPOINTS | jq -r '.endpoints[] | select(.custom_domain == "'"$CUSTOM_DOMAIN_NAME"'") | .id')
        if [ -n "${CDN_ENDPOINT_ID}" ]; then
          echo "Updating an existing CDN endpoint"
          RESPONSE=$(curl -X PUT "https://api.digitalocean.com/v2/cdn/endpoints/$CDN_ENDPOINT_ID" \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $DIGITALOCEAN_TOKEN" \
            -d '{"certificate_id": "'"$CERTIFICATE_ID"'", "custom_domain": "'"$CUSTOM_DOMAIN_NAME"'"}')

          echo $RESPONSE

          echo "Removing old certificates"
          CERTIFICATES=$(curl -X GET "https://api.digitalocean.com/v2/certificates" \
            -H "Authorization: Bearer $DIGITALOCEAN_TOKEN")

          if [ -n "${CERTIFICATES}" ]; then
            # Remove legacy certificates, except the new one.
            CERTIFICATES=$(echo $CERTIFICATES | jq -r '.certificates[] | select(.name | test("'"$UUID_REGEXP.$CUSTOM_DOMAIN_NAME"'")) | select(.id != "'"$CERTIFICATE_ID"'") | .id')
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
            -d '{"origin": "'"$DIGITALOCEAN_CDN_ORIGIN"'", "certificate_id": "'"$CERTIFICATE_ID"'", "custom_domain": "'"$CUSTOM_DOMAIN_NAME"'"}')

          echo $RESPONSE
        fi
      fi
    fi
  fi
}

# Colon-separated values DIGITALOCEAN_CDN_ORIGIN,CUSTOM_DOMAIN_NAME;DIGITALOCEAN_CDN_ORIGIN,CUSTOM_DOMAIN_NAME;...
SPACES=$SPACES

# Backward compatibility for a single domain.
SINGLE_DIGITALOCEAN_CDN_ORIGIN=$DIGITALOCEAN_CDN_ORIGIN
SINGLE_DOMAIN_NAME=$DOMAIN_NAME
if [ -n "$SINGLE_DIGITALOCEAN_CDN_ORIGIN" ] && [ -n "$SINGLE_DOMAIN_NAME" ]; then
  SPACES="$SPACES:$SINGLE_DIGITALOCEAN_CDN_ORIGIN,$SINGLE_DOMAIN_NAME"
fi

if [ -n "${SPACES}" ]; then
  _IFS="$IFS"
  IFS=':' SPACES=($SPACES)
  for SPACE in "${SPACES[@]}"
  do
    IFS=',' read CDN_ORIGIN CUSTOM_DOMAIN <<< "$SPACE"
    IFS="$_IFS" # Reset to default
    if [ -n "$CDN_ORIGIN" ] && [ -n "$CUSTOM_DOMAIN" ]; then
      upload_cert $CDN_ORIGIN $CUSTOM_DOMAIN
    fi
  done
  IFS="$_IFS"
fi
