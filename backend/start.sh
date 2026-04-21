#!/usr/bin/env bash
set -e

cd /var/www/html

php artisan config:cache || true
php artisan route:cache || true
php artisan view:cache || true

php artisan migrate --force || true

php-fpm -D
nginx -g "daemon off;"