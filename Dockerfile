FROM php:7
ENV PORT=8000
RUN apt-get update; apt-get install -y wget libzip-dev
RUN docker-php-ext-install zip pdo_mysql
RUN wget https://raw.githubusercontent.com/composer/getcomposer.org/master/web/installer -O - -q | php -- --install-dir=/usr/local/bin --filename=composer
ENV COMPOSER_ALLOW_SUPERUSER=1
WORKDIR /app
COPY . /app
COPY --from=composer /usr/bin/composer /usr/bin/composer
RUN composer install
RUN touch /app/database/database.sqlite
RUN php artisan config:clear
RUN php artisan key:generate
RUN php artisan config:cache
RUN DB_CONNECTION=sqlite php artisan migrate --force
RUN DB_CONNECTION=sqlite vendor/bin/phpunit
RUN echo "#!/bin/sh\n" \
 "php artisan migrate\n" \
 "php artisan serve --host 0.0.0.0 --port \$PORT" > /app/start.sh
RUN chmod +x /app/start.sh
CMD ["/app/start.sh"]
