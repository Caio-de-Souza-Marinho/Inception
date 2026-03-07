FROM    debian:bullseye

RUN     apt update && \
        apt install -y redis-server && \
        rm -rf /var/lib/apt/lists/*

COPY    tools/entrypoint.sh /entrypoint.sh

RUN     chmod +x /entrypoint.sh

EXPOSE	6379

ENTRYPOINT      ["/entrypoint.sh"]

