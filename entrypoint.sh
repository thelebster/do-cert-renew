#!/bin/bash

printenv

touch /etc/cron.d/crontab \
    && echo DIGITAL_OCEAN_TOKEN=$DIGITAL_OCEAN_TOKEN >> /etc/cron.d/crontab \
    && echo DOMAIN_NAME=$DOMAIN_NAME >> /etc/cron.d/crontab \
    && cat /tmp/crontab >> /etc/cron.d/crontab \
    && cat /etc/cron.d/crontab

chown -R root /etc/cron.d/crontab \
    && chmod 0644 /etc/cron.d/crontab \
    && crontab /etc/cron.d/crontab

exec "$@"
