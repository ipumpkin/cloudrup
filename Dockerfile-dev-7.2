FROM ubuntu:16.04

ENV APACHE_VER="${APACHE_VER}" \
    APP_ROOT="/var/www/html" \
    APACHE_DIR="/etc/apache2"
    
RUN export LC_ALL=C.UTF-8; \
    apt-get update -qq; \
    apt-get install -y software-properties-common python-software-properties; \
    add-apt-repository -y ppa:ondrej/php; \
    add-apt-repository -y ppa:ondrej/apache2; \
  apt-get update -qq && apt-get install -y -qq \
  apache2 \
  php7.2 \
  php7.2-dev \
  libapache2-mod-php7.2 \
  php7.2-cli \
  php7.2-opcache \
  php7.2-json \
  php7.2-xmlrpc \
  php7.2-curl \
  php7.2-ldap \
  php7.2-bz2 \
  php7.2-cgi \
  php7.2-soap \
  php7.2-common \
  php7.2-mbstring \
  php7.2-gd \
  php7.2-intl \
  php7.2-xml \
  php7.2-mysql \
  php7.2-zip \
  php7.2-bcmath \
  sudo \
  rsync \
  git-core \
  unzip \
  wget \
  mysql-client \
  vim \
  openssh-server \
  nodejs-legacy \
  npm; \
  gotpl_url="https://github.com/wodby/gotpl/releases/download/0.1.5/gotpl-linux-amd64-0.1.5.tar.gz"; \
  wget -qO- "${gotpl_url}" | tar xz -C /usr/local/bin; \
  cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime; \
  rm -rf /var/lib/apt/lists/*

# Install redis extension
RUN cd /tmp \
  && git clone --branch 4.3.0 https://github.com/phpredis/phpredis \
  && cd phpredis \
  && phpize \
  && ./configure \
  && make \
  && make install \
  && rm -rf /tmp/phpredis; \
  echo "extension=redis.so" > /etc/php/7.2/mods-available/redis.ini; \
  ln -s /etc/php/7.2/mods-available/redis.ini /etc/php/7.2/apache2/conf.d/30-redis.ini; \
  ln -s /etc/php/7.2/mods-available/redis.ini /etc/php/7.2/cli/conf.d/30-redis.ini

RUN a2enmod rewrite; \
    a2enmod speling; \
    a2enmod proxy; \
    a2enmod proxy_http; \
    a2enmod headers

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"; \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer; \
    php -r "unlink('composer-setup.php');"

RUN wget https://github.com/drush-ops/drush/releases/download/8.2.3/drush.phar -O - -q > /usr/local/bin/drush; \
    chmod +x /usr/local/bin/composer; \
    chmod +x /usr/local/bin/drush; \
    composer config -g repo.packagist composer https://packagist.phpcomposer.com
    
COPY templates /etc/gotpl/
COPY config/php.dev.ini /etc/php/7.2/apache2/php.ini
COPY httpd-foreground-dev /usr/local/bin/httpd-foreground
RUN chmod +x /usr/local/bin/httpd-foreground

WORKDIR $APP_ROOT

# docker-entrypoint.sh waits for mysql and runs hostmaster install
ENTRYPOINT []
CMD ["httpd-foreground"]