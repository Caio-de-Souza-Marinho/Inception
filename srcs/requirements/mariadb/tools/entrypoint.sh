#!/bin/bash

set -e

if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "First time setup: Initializing MariaDB..."

	chown -R mysql:mysql /var/lib/mysql

	# Initialize database files
	mysqld --initialize-insecure --user=mysql --datadir=/var/lib/mysql

	# Start MariaDB in background
	mysqld --skip-networking --user=mysql &

	# Wait until server is ready
	until mysqladmin ping --silent; do
		sleep 1
	done

	# Create database and users
	mysql -u root <<EOF
CREATE DATABASE ${MYSQL_DATABASE};
CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

	# Shutdown temporary server
	mysqladmin -u root -p${MYSQL_ROOT_PASSWORD} shutdown
fi

echo "Starting MariaDB setup..."
exec mysqld --user=mysql
