FROM ubuntu:18.04

MAINTAINER Anton Lebedev <mailbox@lebster.me>

# Install cron.
RUN apt-get update \
    && apt-get -y install cron curl jq

# Install certbot.
RUN apt-get update \
    && apt-get install -y software-properties-common \
    && add-apt-repository -y universe \
    && add-apt-repository -y ppa:certbot/certbot \
    && apt-get update \
    && apt-get -y install certbot

RUN apt-get install -y uuid-runtime

COPY crontab /tmp/crontab
COPY entrypoint.sh /
COPY renew.sh /
COPY upload.sh /
COPY letsencrypt-dns-authenticator.sh /
COPY letsencrypt-dns-cleanup.sh /

RUN chmod +x /entrypoint.sh \
    && chmod +x /renew.sh \
    && chmod +x /upload.sh \
    && chmod +x /letsencrypt-dns-authenticator.sh \
    && chmod +x /letsencrypt-dns-cleanup.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["cron", "-f"]
