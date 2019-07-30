FROM php:7.3-apache-buster
LABEL maintainer="Moravian Library <cpk-dev@mzk.cz>"
LABEL version="1.0"
LABEL description="Based on the 'php:7.3-apache-buster' build with appended modules to php & apache2 + productivity tools included (vim, mc, htop, ping, traceroute, dig, ssh, default-mysql-client, locate, git, curl, bash-completion)"

#
# See the docs for the php docker image:
# - https://hub.docker.com/_/php/
#

ARG PARAM_XDEBUG_ENABLED=false
ARG PARAM_AGGRESSIVE_OPCACHE=false

ARG TMP_DEV_PKGS=" \
        libfreetype6-dev \
        libicu-dev \
        libjpeg62-turbo-dev \
        libldap2-dev \
        libldb-dev \
        libmcrypt-dev \
        libpng-dev \
        libxslt1-dev"

# Install all libraries needed + basic productivity & debug tools
#  NOTE: sorted alphabetically
RUN apt-get update && apt-get install -y \
        bash-completion \
        coreutils \
        curl \
        dnsutils \
        git \
        htop \
        iputils-ping \
        iputils-tracepath \
        libapache2-mod-rpaf \
        libapache2-mod-shib2 \
        mc \
        mlocate \
        default-mysql-client \
        net-tools \
        ssh \
        vim \
        ${TMP_DEV_PKGS} \
    && apt-get clean \
    && apt-get autoremove -y

# Enable apache modules
RUN a2enmod \
        rewrite \
        shib \
        rpaf \
        remoteip \
        proxy \
        proxy_html \
        proxy_http \
        xml2enc

# Prepare for php's ldap extension installation
# https://serverfault.com/questions/633394/php-configure-not-finding-ldap-header-libraries
RUN ln -s /usr/lib/x86_64-linux-gnu/libldap.so /usr/lib/libldap.so \
    && ln -s /usr/lib/x86_64-linux-gnu/liblber.so /usr/lib/liblber.so

RUN docker-php-ext-configure \
        gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) \
        pdo_mysql \
        mysqli \
        intl \
        gd \
        xsl \
        ldap \
        opcache

# Install php modules provided by PECL
RUN pecl install \
        apcu \
        apcu_bc-beta \
        xdebug \
        mcrypt-1.0.2

# Enable all installed modules
RUN docker-php-ext-enable \
        apcu

# Manually enable apc (it's beta version)
# https://github.com/krakjoe/apcu/issues/137#issuecomment-150760383
RUN echo "extension=apc.so \n"\
         "apc.enabled=1 \n"\
         "apc.shm_size=256M \n"\
         "apc.ttl=7200 \n"\
         "apc.enable_cli=1 \n"\
         "apc.gc_ttl=3600 \n"\
         "apc.entries_hint=4096 \n"\
         "apc.slam_defense=1 \n"\
         "apc.serializer=php \n" >> /usr/local/etc/php/conf.d/docker-php-ext-apcu.ini

COPY ./conf/php/php.ini /usr/local/etc/php/php.ini

COPY ./bootstrap-php.sh /onstart/001-php.sh

# Clean up after building from sources
RUN apt-get purge -y \
        ${TMP_DEV_PKGS}

# Update mlocate's files database
RUN updatedb
