#!/bin/bash

# Stops the script, if an error occurred.
set -e

if [ ! -f .env ]; then
  echo "File not found"
  exit 1
fi

if [ ! -s .env ]; then
  echo "File is empty"
  exit 1
fi

if [ ! -f .tmp ] || [ ! -s .tmp ]; then
  echo "File not found or empty"
  exit 1
fi
