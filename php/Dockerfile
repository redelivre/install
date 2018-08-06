FROM php:7.2-fpm
ARG TIMEZONE

RUN apt-get update && apt-get install -y --no-install-recommends \
        curl libcurl4-gnutls-dev locales imagemagick libmagickcore-dev libmagickwand-dev zip \
        ruby ruby-dev libpq-dev gnupg nano iputils-ping git \
        unzip zlibc zlib1g-dev libxml2-dev libicu-dev \
        libz-dev openssl

RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - \
    && apt-get install -y nodejs

RUN npm install -g \
        uglify-js@2.2.0 \
        uglifycss \
        autoprefixer

RUN gem install sass -v 3.4.22

# Install extensions
RUN docker-php-ext-install opcache pdo_pgsql gd zip xml curl json \
 && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
 && docker-php-ext-install pdo pdo_pgsql pdo_mysql intl soap \
 && docker-php-ext-enable pdo pdo_mysql pdo_pgsql intl soap \
 && pecl install apcu \
 && echo "extension=apcu.so" > /usr/local/etc/php/conf.d/apcu.ini \
 && pecl install imagick-beta \
 && echo "extension=imagick.so" > /usr/local/etc/php/conf.d/ext-imagick.ini \
 && pecl install xdebug && docker-php-ext-enable xdebug

# Configure extensions
RUN echo "error_reporting = E_ALL" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "display_startup_errors = On" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "display_errors = On" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_enable=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_connect_back=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.idekey=\"PHPSTORM\"" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_port=9001" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_autostart=off" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "date.timezone = America/Sao_Paulo" >> /usr/local/etc/php/conf.d/php-timezone.ini \
    && echo 'alias sf="php app/console"' >> ~/.bashrc \
    && echo 'alias sf3="php bin/console"' >> ~/.bashrc

# Set timezone
RUN ln -snf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && echo ${TIMEZONE} > /etc/timezone \
&& printf '[PHP]\ndate.timezone = "%s"\n', ${TIMEZONE} > /usr/local/etc/php/conf.d/tzone.ini

WORKDIR /var/www/html
# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
