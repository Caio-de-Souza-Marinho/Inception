#!/bin/bash

set -e

echo "Starting Adminer..."
exec php -S 0.0.0.0:8000 -t /var/www/html
