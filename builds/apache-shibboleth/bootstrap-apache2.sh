#!/usr/bin/env bash


perror() {
    echo "$@" >&2
}

enable_site() {
    local APACHE_CONF_TEMPL="sites-available/$1"
    local APACHE_CONF="sites-available/$2"
    local APACHE_ENABLED_CONF="sites-enabled/$2"

    local APACHE_CONF_TEMPL_ABS_PATH="${APACHE_CONF_DIR}/${APACHE_CONF_TEMPL}"
    if test ! -f "$APACHE_CONF_TEMPL_ABS_PATH"; then
        perror "Apache configuration could not be set! It's missing the template file '$APACHE_CONF_TEMPL_ABS_PATH'"
        return 2
    fi

    local APACHE_CONF_ABS_PATH="${APACHE_CONF_DIR}/${APACHE_CONF}"
    local APACHE_CONF_ENABLED_ABS_PATH="${APACHE_CONF_DIR}/${APACHE_ENABLED_CONF}"

    cp "$APACHE_CONF_TEMPL_ABS_PATH" "$APACHE_CONF_ABS_PATH" || (perror "Failed altering current configuration! Probably wrong permissions?" && return 3)
    echo "$APACHE_CONF_TEMPL_ABS_PATH" "$APACHE_CONF_ABS_PATH"

    sed -i \
        -e "s#PARAM_VUFIND_HOST#${PARAM_VUFIND_HOST:-localhost}#g" \
        -e "s#PARAM_VUFIND_RUN_ENV#${PARAM_VUFIND_RUN_ENV:-development}#g" \
        -e "s#PARAM_VUFIND_LOCAL_MODULES#${PARAM_VUFIND_LOCAL_MODULES:-VuFindConsole,CPK,Statistics,Debug}#g" \
        -e "s#PARAM_VUFIND_SRC#${PARAM_VUFIND_SRC:-/var/www/cpk}#g" \
        -e "s#PARAM_SSL_DIR#${PARAM_SSL_DIR:-/etc/ssl/private}#g" \
        -e "s#PARAM_APACHE_KEY_OUT#${PARAM_APACHE_KEY_OUT:-apache2-key.pem}#g" \
        -e "s#PARAM_APACHE_CRT_OUT#${PARAM_APACHE_CRT_OUT:-apache2-cert.pem}#g" \
        -e "s#PARAM_SENTRY_SECRET_ID#${PARAM_SENTRY_SECRET_ID:-NULL}#g" \
        -e "s#PARAM_SENTRY_USER_ID#${PARAM_SENTRY_USER_ID:-NULL}#g" \
        "$APACHE_CONF_ABS_PATH" || return $?

    if test ! -f "$APACHE_CONF_ENABLED_ABS_PATH"; then
        ln -s "$APACHE_CONF_ABS_PATH" "$APACHE_CONF_ENABLED_ABS_PATH"
    fi
}

enable_port() {
    local APACHE_CONF_PORT="ports.conf"

    local APACHE_CONF_PORT_ABS_PATH="${APACHE_CONF_DIR}/${APACHE_CONF_PORT}"
    if test ! -f "$APACHE_CONF_PORT_ABS_PATH"; then
        perror "Apache '$APACHE_CONF_PORT_ABS_PATH' file is missing!"
        return 4
    fi

    if test "${PARAM_VUFIND_PORT:-443}" -ne "443"; then
        sed -i -e 's#Listen\s*443#Listen '"${PARAM_VUFIND_PORT}"'#g' "$APACHE_CONF_PORT_ABS_PATH"
    fi
}

# Generate self-signed SSL/TLS certificates
#  - https://stackoverflow.com/questions/10175812/how-to-create-a-self-signed-certificate-with-openssl
generate_keys() {
    local KEY_FILE="$1"
    local CRT_FILE="$2"

    if test -f "$KEY_FILE"; then
        return 0
    fi

    openssl req \
        -x509 \
        -newkey rsa:4096 \
        -nodes \
        -keyout "$KEY_FILE" \
        -out "$CRT_FILE" \
        -days ${SSL_VALIDITY_DAYS} \
        -subj '/CN=${PARAM_VUFIND_HOST}'
}

main() {
    APACHE_CONF_DIR="/etc/apache2"

    enable_site "000-default.conf.templ" "000-default.conf" || return $?
    enable_site "001-default-ssl.conf.templ" "001-default-ssl.conf" || return $?
    generate_keys "$PARAM_SSL_DIR/$PARAM_SHIB_KEY_OUT" "$PARAM_SSL_DIR/$PARAM_SHIB_CRT_OUT" || return $?
    generate_keys "$PARAM_SSL_DIR/$PARAM_APACHE_KEY_OUT" "$PARAM_SSL_DIR/$PARAM_APACHE_CRT_OUT" || return $?
    enable_port || return $?

    unset APACHE_CONF_DIR
}

main "$@"
exit $?
