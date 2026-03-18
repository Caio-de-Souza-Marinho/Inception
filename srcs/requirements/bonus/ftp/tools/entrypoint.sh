#!/bin/bash

set -e

FTP_PASSWORD=$(cat /run/secrets/ftp_password)

# Create required vsftp directory
mkdir -p /var/run/vsftpd/empty

# Create FTP user if it doesn't exist
if ! id "${FTP_USER}" &>/dev/null; then
	useradd -m -d /var/www/html "${FTP_USER}"
	echo "${FTP_USER}:${FTP_PASSWORD}" | chpasswd
	usermod -aG www-data "${FTP_USER}"
fi

echo "Starting FTP server..."
exec vsftpd /etc/vsftpd.conf
