#!/bin/bash

set -e
	
MYSQL_PASSWORD=$(cat /run/secrets/db_password)
MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

# Create socket directory
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld
chown -R mysql:mysql /var/lib/mysql

if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
	echo "First time setup: Initializing MariaDB..."

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
CREATE USER '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'localhost';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF

	# Shutdown temporary server
	mysqladmin -u root -p${MYSQL_ROOT_PASSWORD} shutdown
	echo "MariaDB initialized successfully."
fi

echo "Starting MariaDB..."
exec mysqld --user=mysql
