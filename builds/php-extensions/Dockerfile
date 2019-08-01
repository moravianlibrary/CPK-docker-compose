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
ARG PARAM_XDEBUG_PROFILER_TRIGGER_VALUE=

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
        gnupg \
        locales \
        ${TMP_DEV_PKGS} \
    && apt-get clean \
    && apt-get autoremove -y

# Set Czech locales
RUN sed -i -e 's/# cs_CZ.UTF-8 UTF-8/cs_CZ.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
ENV LC_ALL=cs_CZ.UTF-8
ENV LANG=cs_CZ.UTF-8
ENV LANGUAGE=cs_CZ.UTF-8

# Enable apache modules
RUN a2enmod \
        rewrite \
        shib \
        rpaf \
        remoteip \
        proxy \
        proxy_html \
        proxy_http \
        expires \
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

RUN echo "opcache.enable=1 \n"\
         "opcache.memory_consumption=128 \n"\
         "opcache.max_accelerated_files=8000 \n" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini

COPY ./bootstrap-php.sh /onstart/001-php.sh
COPY ./bootstrap-newrelic.sh /onstart/002-newrelic.sh

# Enable NewRelic
RUN curl --silent https://download.newrelic.com/548C16BF.gpg | apt-key add -
RUN echo "deb http://apt.newrelic.com/debian/ newrelic non-free" > /etc/apt/sources.list.d/newrelic.list
RUN apt update && apt install -y newrelic-php5 && apt-get clean
# Add newrelic .so module
RUN NR_INSTALL_SILENT=1 newrelic-install  install ; rm /usr/local/etc/php/conf.d/newrelic.ini
COPY conf/php/newrelic.ini /usr/local/etc/php/conf.d/newrelic.ini.disabled


# Clean up after building from sources
RUN apt-get purge -y \
        ${TMP_DEV_PKGS}

# Update mlocate's files database
RUN updatedb
