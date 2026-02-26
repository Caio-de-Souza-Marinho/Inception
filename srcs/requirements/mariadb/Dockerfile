FROM	debian:bullseye

RUN	apt update && \
	apt install -y mariadb-server && \
	rm -rf /var/lib/apt/lists/*

COPY	tools/entrypoint.sh /entrypoint.sh

RUN	chmod +x /entrypoint.sh

ENTRYPOINT	["/entrypoint.sh"]
