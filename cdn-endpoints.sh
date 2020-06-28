#!/bin/bash

# Stops the script, if an error occurred.
set -e

DIGITALOCEAN_TOKEN=$DIGITALOCEAN_TOKEN
DOMAIN_NAME=$DOMAIN_NAME

CDN_ENDPOINTS=$(curl -X GET "https://api.digitalocean.com/v2/cdn/endpoints" \
  -H "Authorization: Bearer $DIGITALOCEAN_TOKEN")

if [ -n "${CDN_ENDPOINTS}" ]; then
  echo $CDN_ENDPOINTS
  CDN_ENDPOINT_ID=$(echo $CDN_ENDPOINTS | jq -r '.endpoints[] | select(.custom_domain == "'"$DOMAIN_NAME"'") | .id')
  if [ -n "${CDN_ENDPOINT_ID}" ]; then
    echo $CDN_ENDPOINT_ID
  fi
fi
