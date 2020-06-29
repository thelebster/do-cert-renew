#!/bin/bash

# Stops the script, if an error occurred.
set -e

if echo "unexpected error occurred" | grep -qi "unexpected error occurred"; then
  echo "An unexpected error occurred"
  exit 1
fi

echo "¯\_(ツ)_/¯"
