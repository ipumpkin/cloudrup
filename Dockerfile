FROM ubuntu:14.04

RUN apt-get update -qq && apt-get install -y -qq\
  apache2 \
  php5 \
  php5-cli \
  php5-gd \
  php5-mysql \
  php-pear \
  php5-curl \
  postfix \
  sudo \
  rsync \
  git-core \
  unzip \
  wget \
  mysql-client

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
RUN a2enmod rewrite

# Save a symlink to the /var/aegir/config/docker.conf file.
RUN mkdir -p /var/aegir/config
RUN chown aegir:aegir /var/aegir/config -R
RUN mkdir /var/aegir/.ssh
RUN chown aegir:aegir /var/aegir/.ssh -R
RUN chmod 750 /var/aegir/.ssh

RUN ln -sf /var/aegir/config/apache.conf /etc/apache2/conf-available/aegir.conf
RUN ln -sf /etc/apache2/conf-available/aegir.conf /etc/apache2/conf-enabled/aegir.conf

COPY sudoers-aegir /etc/sudoers.d/aegir
RUN chmod 0440 /etc/sudoers.d/aegir

RUN wget https://raw.githubusercontent.com/composer/getcomposer.org/1b137f8bf6db3e79a38a5bc45324414a6b1f9df2/web/installer -O - -q | php -- --quiet
RUN cp composer.phar /usr/local/bin/composer

RUN wget http://files.drush.org/drush.phar -O - -q > /usr/local/bin/drush
RUN chmod +x /usr/local/bin/composer
RUN chmod +x /usr/local/bin/drush

# Prepare Aegir Logs folder.
RUN mkdir /var/log/aegir
RUN chown aegir:aegir /var/log/aegir
RUN echo 'Hello, Cloudrup.' > /var/log/aegir/system.log

COPY httpd-foreground /usr/local/bin/httpd-foreground
RUN chmod +x /usr/local/bin/httpd-foreground

USER aegir
WORKDIR /var/aegir
VOLUME /var/aegir

# docker-entrypoint.sh waits for mysql and runs hostmaster install
ENTRYPOINT []
CMD ["httpd-foreground"]