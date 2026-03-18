#!/bin/bash

MYSQL_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)

# Wait for MariaDB to be ready
until mysqladmin ping -h mariadb -u "${MYSQL_USER}" -p"${MYSQL_PASSWORD}" --silent; do
	echo "Waiting for MariaDB..."
	sleep 2
done

if [ ! -f /var/www/html/wp-config.php ]; then
	echo "Setting up WordPress..."

	# Download WordPress core
	wp core download --allow-root --locale=en_US

	# Create wp-config.php
	wp config create \
		--allow-root \
		--dbname="${MYSQL_DATABASE}" \
		--dbuser="${MYSQL_USER}" \
		--dbpass="${MYSQL_PASSWORD}" \
		--dbhost=mariadb

	# Install WordPress
	wp core install \
		--allow-root \
		--url="https://${DOMAIN_NAME}" \
		--title="Inception" \
		--admin_user="${WP_ADMIN_USER}" \
		--admin_password="${WP_ADMIN_PASSWORD}" \
		--admin_email="${WP_ADMIN_EMAIL}" \

	# Create a second regular user
	wp user create \
		--allow-root \
		"${WP_USER}" "${WP_USER_EMAIL}" \
		--user_pass="${WP_ADMIN_PASSWORD}" \
		--role=author

	# Configure Redis
	wp config set --allow-root WP_CACHE true --raw
	wp config set --allow-root WP_REDIS_HOST "${REDIS_HOST}"
	wp config set --allow-root WP_REDIS_PORT "${REDIS_PORT}" --raw

	wp plugin install classic-editor --activate --allow-root
	wp plugin install redis-cache --activate --allow-root

	wp redis enable --allow-root

	echo "WordPress setup complete."
fi

# Fix ownership so www-data can write
chown -R www-data:www-data /var/www/html

echo "Starting php-fpm..."

exec php-fpm7.4 -F
