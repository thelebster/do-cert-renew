#!/bin/bash

# Stops the script, if an error occurred.
set -e

DIGITALOCEAN_TOKEN=$DIGITALOCEAN_TOKEN
DOMAIN_NAME=$DOMAIN_NAME

CERTIFICATES=$(curl -X GET "https://api.digitalocean.com/v2/certificates" \
    -H "Authorization: Bearer $DIGITALOCEAN_TOKEN")

if [ -n "${CERTIFICATES}" ]; then
  echo $CERTIFICATES
fi
