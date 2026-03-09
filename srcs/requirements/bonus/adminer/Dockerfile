FROM	debian:bullseye

RUN	apt update && \
	apt upgrade -y php php-mysqli wget && \
	rm -rf /var/lib/apt/lists/*

RUN	wget https://www.adminer.org/latest.php -O /var/www/html/adminer.php

COPY	tools/entrypoint.sh /entrypoint.sh

RUN	chmod +x /entrypoint.sh

EXPOSE	8888

ENTRYPOINT	["/entrypoint.sh"]
