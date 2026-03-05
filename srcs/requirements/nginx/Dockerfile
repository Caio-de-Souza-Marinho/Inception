FROM    debian:bullseye

RUN     apt update && \
        apt install -y nginx openssl && \
        rm -rf /var/lib/apt/lists/*

RUN	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
		-keyout /etc/ssl/private/nginx.key \
		-out /etc/ssl/certs/nginx.crt \
		-subj "/C=BR/ST=SP/L=SaoPaulo/O=42/OU=inception/CN=caide-so.42.fr"

COPY    conf/nginx.conf /etc/nginx/sites-available/default

COPY    tools/entrypoint.sh /entrypoint.sh

RUN     chmod +x /entrypoint.sh

EXPOSE  443

ENTRYPOINT      ["/entrypoint.sh"]

