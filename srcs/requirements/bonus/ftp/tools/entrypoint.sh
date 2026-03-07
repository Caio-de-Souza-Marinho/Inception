#!/bin/bash

set -e

FTP_PASSWORD=$(cat /run/secrets/ftp_password)

chown -R "${FTP_USER}:${FTP_USER}" /var/www/html

# Create FTP user if it doesn't exist
if ! id "${FTP_USER}" &>/dev/null; then
	useradd -m -d /var/www/html "${FTP_USER}"
	echo "${FTP_USER}:${FTP_PASSWORD}" | chpasswd
fi

# Create required vsftp directory
mkdir -p /var/run/vsftp/empty

echo "Starting FTP server..."
exec vsftpd /etc/vsftpd.conf
