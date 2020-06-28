#!/bin/bash

# Stops the script, if an error occurred.
set -e

DIGITALOCEAN_TOKEN=$DIGITALOCEAN_TOKEN
DOMAIN_NAME=$DOMAIN_NAME
UUID_REGEXP='[0-9a-fA-F]{8}\\-[0-9a-fA-F]{4}\\-[0-9a-fA-F]{4}\\-[0-9a-fA-F]{4}\\-[0-9a-fA-F]{12}'
CERTIFICATE_ID="779359d6-f14a-4504-b05a-3c4216c0ee6a"

CERTIFICATES=$(curl -X GET "https://api.digitalocean.com/v2/certificates" \
  -H "Authorization: Bearer $DIGITALOCEAN_TOKEN")

if [ -n "${CERTIFICATES}" ]; then
  CERTIFICATES=$(echo $CERTIFICATES | jq -r '.certificates[] | select(.name | test("'"$UUID_REGEXP.$DOMAIN_NAME"'")) | select(.id != "'"$CERTIFICATE_ID"'") | .id')
  for CERT_ID in $CERTIFICATES
  do
    echo $CERT_ID
  done
fi
