FROM	debian:bullseye

RUN	apt update && \
	apt install -y curl && \
	rm -rf /var/lib/apt/lists/*

RUN	curl -L https://github.com/portainer/portainer/releases/download/2.19.4/portainer-2.19.4-linux-amd64.tar.gz \
	| tar -xz -C /opt

EXPOSE	9000

ENTRYPOINT ["/opt/portainer/portainer", "--admin-password", "$2y$05$t1k/kArzUhoTyKzBxpgS4u8hPSbfgB5dW1CYu/EN0n7d3sGa6L63e"]


