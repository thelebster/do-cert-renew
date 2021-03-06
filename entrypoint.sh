#!/bin/bash

# Stops the script, if an error occurred.
set -e

touch rm -f /etc/cron.d/crontab \
    && touch /etc/cron.d/crontab \
    && echo DIGITALOCEAN_TOKEN=$DIGITALOCEAN_TOKEN >> /etc/cron.d/crontab \
    && echo DIGITALOCEAN_CDN_ORIGIN=$DIGITALOCEAN_CDN_ORIGIN >> /etc/cron.d/crontab \
    && echo DOMAIN_NAME=$DOMAIN_NAME >> /etc/cron.d/crontab \
    && echo LETSENCRYPT_EMAIL=$LETSENCRYPT_EMAIL >> /etc/cron.d/crontab \
    && echo CLOUDFLARE_API_KEY=$CLOUDFLARE_API_KEY >> /etc/cron.d/crontab \
    && echo CLOUDFLARE_EMAIL=$CLOUDFLARE_EMAIL >> /etc/cron.d/crontab \
    && if [ -n "${SPACES}" ]; then echo SPACES=$SPACES >> /etc/cron.d/crontab; fi \
    && if [ -n "${CERTBOT_ARGS}" ]; then echo CERTBOT_ARGS=$CERTBOT_ARGS >> /etc/cron.d/crontab; fi \
    && cat /tmp/crontab >> /etc/cron.d/crontab \
    && cat /etc/cron.d/crontab

chown -R root /etc/cron.d/crontab \
    && chmod 0644 /etc/cron.d/crontab \
    && crontab /etc/cron.d/crontab

exec "$@"
