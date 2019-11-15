FROM ubuntu:16.04
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG C.UTF-8

RUN export LC_ALL=C.UTF-8; \
  apt-get update -qq; \
  apt-get install -y software-properties-common python-software-properties; \
  add-apt-repository -y ppa:ondrej/php; \
  apt-get update -qq && apt-get install -y -qq \
  apache2 \
  php7.1 \
  php7.1-dev \
  libapache2-mod-php7.1 \
  php7.1-cli \
  php7.1-opcache \
  php7.1-json \
  php7.1-xmlrpc \
  php7.1-curl \
  php7.1-ldap \
  php7.1-bz2 \
  php7.1-cgi \
  php7.1-soap \
  php7.1-common \
  php7.1-mbstring \
  php7.1-gd \
  php7.1-intl \
  php7.1-xml \
  php7.1-mysql \
  php7.1-mcrypt \
  php7.1-zip \
  php7.1-fpm \
  php7.1-imap \
  libpcre3-dev \
  php-sqlite3 \
  php-apcu \
  postfix \
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

RUN echo "extension=redis.so" > /etc/php/7.1/mods-available/redis.ini
RUN ln -s /etc/php/7.1/mods-available/redis.ini /etc/php/7.1/apache2/conf.d/30-redis.ini
RUN ln -s /etc/php/7.1/mods-available/redis.ini /etc/php/7.1/cli/conf.d/30-redis.ini

# Use --build-arg option when running docker build to set these variables.
# If wish to "mount" a volume to your host, set AEGIR_UID and AEGIR_GIT to your local user's UID.
# There are both ARG and ENV lines to make sure the value persists.
# See https://docs.docker.com/engine/reference/builder/#/arg
ARG AEGIR_UID=1000
ENV AEGIR_UID ${AEGIR_UID:-1000}

RUN echo "Creating user aegir with UID $AEGIR_UID and GID $AEGIR_GID"

RUN addgroup --gid $AEGIR_UID aegir
RUN adduser --uid $AEGIR_UID --gid $AEGIR_UID --system --shell /bin/bash --home /var/aegir aegir
RUN adduser aegir www-data
RUN a2enmod rewrite
RUN a2enmod ssl
RUN ln -s /var/aegir/config/apache.conf /etc/apache2/conf-available/aegir.conf
RUN ln -s /etc/apache2/conf-available/aegir.conf /etc/apache2/conf-enabled/aegir.conf

COPY sudoers-aegir /etc/sudoers.d/aegir
RUN chmod 0440 /etc/sudoers.d/aegir

COPY crontab-aegir /etc/cron.d/aegir
RUN chmod 0644 /etc/cron.d/aegir
RUN crontab -u aegir /etc/cron.d/aegir

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php composer-setup.php --install-dir=/usr/local/bin --filename=composer
RUN php -r "unlink('composer-setup.php');"

RUN wget https://github.com/drush-ops/drush/releases/download/8.2.3/drush.phar -O - -q > /usr/local/bin/drush
RUN chmod +x /usr/local/bin/composer
RUN chmod +x /usr/local/bin/drush

# Install fix-permissions and fix-ownership scripts
RUN wget http://cgit.drupalcode.org/hosting_tasks_extra/plain/fix_permissions/scripts/standalone-install-fix-permissions-ownership.sh
RUN bash standalone-install-fix-permissions-ownership.sh

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

COPY run-tests.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/run-tests.sh

#COPY docker-entrypoint-tests.sh /usr/local/bin/
#RUN chmod +x /usr/local/bin/docker-entrypoint-tests.sh

COPY docker-entrypoint-queue.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint-queue.sh

# Prepare Aegir Logs folder.
RUN mkdir /var/log/aegir
RUN chown aegir:aegir /var/log/aegir
RUN echo 'Hello, Aegir.' > /var/log/aegir/system.log

# Don't install provision. Downstream tags will do this with the right version.
## Install Provision for all.
#ENV PROVISION_VERSION 7.x-3.x
#RUN mkdir -p /usr/share/drush/commands
#RUN drush dl --destination=/usr/share/drush/commands provision-$PROVISION_VERSION -y
ENV REGISTRY_REBUILD_VERSION 7.x-2.5
RUN drush dl --destination=/usr/share/drush/commands registry_rebuild-$REGISTRY_REBUILD_VERSION -y

RUN git clone https://github.com/ipumpkin/provision-1.git --branch cloudrup /usr/share/drush/commands/provision
RUN systemctl enable ssh

USER aegir

RUN mkdir /var/aegir/config
RUN mkdir /var/aegir/.drush

# You may change this environment at run time. User UID 1 is created with this email address.
ENV AEGIR_CLIENT_EMAIL aegir@aegir.local.computer
ENV AEGIR_CLIENT_NAME admin
ENV AEGIR_PROFILE hostmaster
ENV AEGIR_VERSION 7.x-3.x
ENV PROVISION_VERSION 7.x-3.x
ENV AEGIR_WORKING_COPY 0

# Must be fixed across versions so we can upgrade containers.
ENV AEGIR_HOSTMASTER_ROOT /var/aegir/hostmaster

WORKDIR /var/aegir

# The Hostname of the database server to use
ENV AEGIR_DATABASE_SERVER database

# For dev images (7.x-3.x branch)
ENV AEGIR_MAKEFILE http://cgit.drupalcode.org/provision/plain/aegir.make

# For Releases:
# ENV AEGIR_MAKEFILE http://cgit.drupalcode.org/provision/plain/aegir-release.make?h=$AEGIR_VERSION

VOLUME /var/aegir

# docker-entrypoint.sh waits for mysql and runs hostmaster install
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["drush", "@hostmaster", "hosting-queued"]
