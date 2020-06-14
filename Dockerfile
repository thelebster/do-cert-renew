FROM ubuntu:18.04

MAINTAINER Anton Lebedev <mailbox@lebster.me>

RUN apt-get update && apt-get -y install cron curl

COPY crontab /tmp/crontab
COPY entrypoint.sh /
COPY renew.sh /

RUN chmod +x /entrypoint.sh && chmod +x /renew.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["cron", "-f"]
