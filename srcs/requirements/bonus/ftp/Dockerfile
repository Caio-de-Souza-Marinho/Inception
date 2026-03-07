FROM	debian:bullseye

RUN	apt update && \
	apt install -y vsftpd && \
	rm -rf /var/lib/apt/lists/*

COPY	conf/vsftpd.conf /etc/vsftpd.conf

COPY	tools/entrypoint.sh /entrypoint.sh

RUN	chmod +x /entrypoint.sh

EXPOSE	21 21000-21010

ENTRYPOINT	["/entrypoint.sh"]
