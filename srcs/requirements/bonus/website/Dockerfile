FROM	debian:bullseye

RUN	apt update && \
	apt install -y nginx && \
	rm -rf /var/lib/apt/lists/*

COPY	www/index.html /var/www/html/index.html
COPY	conf/nginx.conf /etc/nginx/sites-available/default

EXPOSE	8080

CMD ["nginx", "-g", "daemon off;"]
