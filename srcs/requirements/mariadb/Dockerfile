FROM	debian:bullseye

RUN	apt update && \
	apt install -y mariadb-server && \
	rm -rf /var/lib/apt/lists/*

RUN	printf '[mysqld]\nbind-address=0.0.0.0\nport=3306\n' \
		> /etc/mysql/mariadb.conf.d/50-server.cnf

COPY	tools/entrypoint.sh /entrypoint.sh

RUN	chmod +x /entrypoint.sh

ENTRYPOINT	["/entrypoint.sh"]
