#!/usr/bin/env bash
set -e

cd /var/www/html

php artisan migrate --force || true
php artisan db:seed --force || true

php-fpm -D
nginx -g "daemon off;"