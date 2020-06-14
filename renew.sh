#!/bin/bash

# Stops the script, if an error occurred.
set -e

printenv

DIGITAL_OCEAN_TOKEN=$DIGITAL_OCEAN_TOKEN
DOMAIN_NAME=$DOMAIN_NAME

curl -X GET "https://api.digitalocean.com/v2/certificates" \
	-H "Authorization: Bearer $DIGITAL_OCEAN_TOKEN"
