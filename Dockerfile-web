FROM ubuntu:16.04

ENV LANG C.UTF-8
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
  openssh-server; \
  rm -rf /var/lib/apt/lists/*

# Install redis extension
RUN cd /tmp \
  && git clone --branch 4.3.0 https://github.com/phpredis/phpredis \
  && cd phpredis \
  && phpize \
  && ./configure \
  && make \
  && make install \
  && rm -rf /tmp/phpredis

RUN echo "extension=redis.so" > /etc/php/7.2/mods-available/redis.ini
RUN ln -s /etc/php/7.2/mods-available/redis.ini /etc/php/7.2/apache2/conf.d/30-redis.ini
RUN ln -s /etc/php/7.2/mods-available/redis.ini /etc/php/7.2/cli/conf.d/30-redis.ini

# Use --build-arg option when running docker build to set these variables.
# If wish to "mount" a volume to your host, set AEGIR_UID and AEGIR_GIT to your local user's UID.
# There are both ARG and ENV lines to make sure the value persists.
# See https://docs.docker.com/engine/reference/builder/#/arg
ARG AEGIR_UID=1000
ENV AEGIR_UID ${AEGIR_UID:-1000}

RUN echo "Creating user aegir with UID $AEGIR_UID and GID $AEGIR_GID"

RUN addgroup --gid $AEGIR_UID aegir
RUN adduser --uid $AEGIR_UID --gid $AEGIR_UID --system --home /var/aegir aegir
RUN adduser aegir www-data
RUN usermod aegir -s /bin/bash

RUN a2enmod rewrite; \
  a2enmod speling; \
  a2enmod headers

# Save a symlink to the /var/aegir/config/docker.conf file.
RUN mkdir -p /var/aegir/config
RUN echo "" > /var/aegir/config/apache.conf
RUN chown aegir:aegir /var/aegir/config -R
RUN mkdir /var/aegir/.ssh
RUN chown aegir:aegir /var/aegir/.ssh -R
RUN chmod 750 /var/aegir/.ssh

RUN ln -sf /var/aegir/config/apache.conf /etc/apache2/conf-available/aegir.conf
RUN ln -sf /etc/apache2/conf-available/aegir.conf /etc/apache2/conf-enabled/aegir.conf

COPY sudoers-aegir /etc/sudoers.d/aegir
RUN chown root:root /etc/sudoers.d/aegir
RUN chmod 0440 /etc/sudoers.d/aegir

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php --install-dir=/usr/local/bin --filename=composer
RUN php -r "unlink('composer-setup.php');"

RUN wget https://github.com/drush-ops/drush/releases/download/8.2.3/drush.phar -O - -q > /usr/local/bin/drush
RUN chmod +x /usr/local/bin/composer
RUN chmod +x /usr/local/bin/drush

# Prepare Aegir Logs folder.
RUN mkdir /var/log/aegir
RUN chown aegir:aegir /var/log/aegir
RUN echo 'Hello, Cloudrup.' > /var/log/aegir/system.log

COPY httpd-foreground /usr/local/bin/httpd-foreground
RUN chmod +x /usr/local/bin/httpd-foreground
COPY config/other-vhosts-access-log.conf /etc/apache2/conf-available/other-vhosts-access-log.conf
COPY config/security.conf /etc/apache2/conf-available/security.conf

RUN systemctl enable ssh

USER aegir
WORKDIR /var/aegir
VOLUME /var/aegir

# docker-entrypoint.sh waits for mysql and runs hostmaster install
ENTRYPOINT []
CMD ["httpd-foreground"]