FROM	debian:bullseye

RUN	apt update && \
	apt install -y php php-mysqli wget && \
	rm -rf /var/lib/apt/lists/*

RUN	wget https://www.adminer.org/latest.php -O /var/www/html/index.php

COPY	tools/entrypoint.sh /entrypoint.sh

RUN	chmod +x /entrypoint.sh

EXPOSE	8000

ENTRYPOINT	["/entrypoint.sh"]
