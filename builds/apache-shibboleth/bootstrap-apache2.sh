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

    PARAM_VUFIND_SSL_URL="https://$PARAM_VUFIND_HOST:$PARAM_VUFIND_SSL_PORT"

    local APACHE_CONF_ABS_PATH="${APACHE_CONF_DIR}/${APACHE_CONF}"
    local APACHE_CONF_ENABLED_ABS_PATH="${APACHE_CONF_DIR}/${APACHE_ENABLED_CONF}"

    cp "$APACHE_CONF_TEMPL_ABS_PATH" "$APACHE_CONF_ABS_PATH" || (perror "Failed altering current configuration! Probably wrong permissions?" && return 3)

    if [ -z "$PARAM_VUFIND_SRC" ]; then
        PARAM_VUFIND_SRC="/var/www/cpk"
    fi;

    if [ -z "$PARAM_VUFIND_CONFIG_DIR" ]; then
        PARAM_VUFIND_CONFIG_DIR="knihovny"
    fi;

    # Backward compability with previous configuration layout
    VUFIND_CONFIG_DIR="${PARAM_VUFIND_SRC}/local/${PARAM_VUFIND_CONFIG_DIR}"
    if [[ "$PARAM_VUFIND_CONFIG_DIR" == "knihovny" && ! -d "$VUFIND_CONFIG_DIR" ]] ; then
        PARAM_VUFIND_CONFIG_DIR=""
    fi;

    sed -i \
        -e "s#PARAM_VUFIND_HOST#${PARAM_VUFIND_HOST:-localhost}#g" \
        -e "s#PARAM_VUFIND_RUN_ENV#${PARAM_VUFIND_RUN_ENV:-development}#g" \
        -e "s#PARAM_VUFIND_LOCAL_MODULES#${PARAM_VUFIND_LOCAL_MODULES:-VuFindConsole,CPK,Statistics,Debug}#g" \
        -e "s#PARAM_VUFIND_SRC#${PARAM_VUFIND_SRC}#g" \
        -e "s#PARAM_VUFIND_CONFIG_DIR#${PARAM_VUFIND_CONFIG_DIR}#g" \
        -e "s#PARAM_SSL_DIR#${PARAM_SSL_DIR:-/etc/ssl/private}#g" \
        -e "s#PARAM_APACHE_KEY_OUT#${PARAM_APACHE_KEY_OUT:-apache2-key.pem}#g" \
        -e "s#PARAM_APACHE_CRT_OUT#${PARAM_APACHE_CRT_OUT:-apache2-cert.pem}#g" \
        -e "s#PARAM_SENTRY_SECRET_ID#${PARAM_SENTRY_SECRET_ID:-NULL}#g" \
        -e "s#PARAM_SENTRY_USER_ID#${PARAM_SENTRY_USER_ID:-NULL}#g" \
        -e "s#PARAM_VUFIND_SSL_URL#${PARAM_VUFIND_SSL_URL}#g" \
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

main() {
    APACHE_CONF_DIR="/etc/apache2"

    enable_site "000-default.conf.templ" "000-default.conf" || return $?
    if [ "$PARAM_SSL_ENABLED" == true ]; then
        a2enmod ssl || return $?
        enable_site "001-default-ssl.conf.templ" "001-default-ssl.conf" || return $?
        /usr/local/bin/generate_key.sh "$PARAM_SSL_DIR/$PARAM_APACHE_KEY_OUT" "$PARAM_SSL_DIR/$PARAM_APACHE_CRT_OUT" \
            "$PARAM_VUFIND_HOST" "$PARAM_SSL_VALIDITY_DAYS" || return $?
    fi;
    enable_port || return $?

    unset APACHE_CONF_DIR
}

main "$@"
exit $?
