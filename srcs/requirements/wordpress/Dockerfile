FROM    debian:bullseye

RUN     apt update && \
        apt install -y \
	php7.4-fpm \
	php7.4-mysql \
	wget \
	curl \
	mariadb-client && \
        rm -rf /var/lib/apt/lists/*

RUN	wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
	chmod +x wp-cli.phar && \
	mv wp-cli.phar /usr/local/bin/wp

RUN	mkdir -p /run/php && \
	sed -i 's/listen = \/run\/php\/php7.4-fpm.sock/listen = 9000/' \
		/etc/php/7.4/fpm/pool.d/www.conf

COPY    tools/entrypoint.sh /entrypoint.sh

RUN     chmod +x /entrypoint.sh

WORKDIR /var/www/html

EXPOSE	9000

ENTRYPOINT      ["/entrypoint.sh"]
