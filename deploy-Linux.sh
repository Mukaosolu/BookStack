#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

APP_DIR="/var/www/bookstack"

echo "🔵 Stopping Apache..."
sudo systemctl stop apache2

echo "🔵 Cleaning previous deployment files..."
sudo rm -rf ${APP_DIR}/*

echo "🔵 Unzipping new release..."
sudo unzip -o /tmp/deploy/bookstack.zip -d ${APP_DIR}/

echo "🔵 Setting correct ownership and permissions..."
sudo chown -R www-data:www-data ${APP_DIR}
sudo chmod -R 755 ${APP_DIR}

echo "🔵 Running Composer install (production mode)..."
cd ${APP_DIR}
sudo -u www-data composer install --no-dev --optimize-autoloader

echo "🔵 Running database migrations..."
sudo -u www-data php artisan migrate --force

echo "🔵 Clearing and caching configurations..."
sudo -u www-data php artisan config:clear
sudo -u www-data php artisan config:cache
sudo -u www-data php artisan route:cache
sudo -u www-data php artisan view:cache

echo "🔵 Starting Apache..."
sudo systemctl start apache2

echo "✅ Deployment completed successfully!"
