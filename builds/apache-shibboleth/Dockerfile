FROM localhost/php-extensions

ARG PARAM_VUFIND_HOST="localhost"
ARG PARAM_SSL_DIR="/etc/ssl/private"
ARG PARAM_SHIB_KEY_OUT="shibboleth2-sp-key.pem"
ARG PARAM_SHIB_CRT_OUT="shibboleth2-sp-cert.pem"
ARG PARAM_APACHE_KEY_OUT="apache2-key.pem"
ARG PARAM_APACHE_CRT_OUT="apache2-cert.pem"
ARG SSL_VALIDITY_DAYS=3650

# These scripts will make sure for proper configuration
COPY ./bootstrap-shibboleth2.sh /onstart/001-shibboleth2.sh
COPY ./bootstrap-apache2.sh /onstart/002-apache2.sh


# What was specified as argument on build time, pass as ENV
ENV PARAM_VUFIND_HOST=${PARAM_VUFIND_HOST}
ENV PARAM_SSL_DIR=${PARAM_SSL_DIR}
ENV PARAM_SHIB_KEY_OUT=${PARAM_SHIB_KEY_OUT}
ENV PARAM_SHIB_CRT_OUT=${PARAM_SHIB_CRT_OUT}
ENV PARAM_APACHE_KEY_OUT=${PARAM_APACHE_KEY_OUT}
ENV PARAM_APACHE_CRT_OUT=${PARAM_APACHE_CRT_OUT}
ENV SSL_VALIDITY_DAYS=${SSL_VALIDITY_DAYS}

# Prepare these ENVs for filling from secrets
ENV PARAM_SENTRY_SECRET_ID={{DOCKER-SECRET:PARAM_SENTRY_SECRET_ID}}
ENV PARAM_SENTRY_USER_ID={{DOCKER-SECRET:PARAM_SENTRY_USER_ID}}
