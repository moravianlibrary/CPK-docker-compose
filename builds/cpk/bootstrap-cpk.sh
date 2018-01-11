#!/usr/bin/env bash

perror() {
    echo "$@" >&2
}

main() {

    CONFIG_LOCAL="${PARAM_VUFIND_SRC}/local/config/vufind/config.local.ini"
    if [ -f "$CONFIG_LOCAL" ]; then
        return 0
    fi;

    cp /tmp/config.local.template.ini "$CONFIG_LOCAL"
    sed -i \
      -e "s#PARAM_VUFIND_DEBUG#${PARAM_VUFIND_DEBUG:-false}#g" \
      -e "s#PARAM_VUFIND_CAPTCHA_SITE_KEY#${PARAM_VUFIND_CAPTCHA_SITE_KEY}#g" \
      -e "s#PARAM_VUFIND_CAPTCHA_SECRET_KEY#${PARAM_VUFIND_CAPTCHA_SECRET_KEY}#g" \
      -e "s#PARAM_VUFIND_URL#${PARAM_VUFIND_URL}#g" \
      -e "s#PARAM_VUFIND_SOLR_URL#${PARAM_VUFIND_SOLR_URL}#g" \
      -e "s#PARAM_VUFIND_SOLR_INDEX#${PARAM_VUFIND_SOLR_INDEX}#g" \
      -e "s#PARAM_VUFIND_MYSQL_URL#${PARAM_VUFIND_MYSQL_URL}#g" \
      -e "s#PARAM_VUFIND_GOOGLE_API_KEY#${PARAM_VUFIND_GOOGLE_API_KEY}#g" \
      -e "s#PARAM_VUFIND_INFO_KNIHOVNY#${PARAM_VUFIND_INFO_KNIHOVNY}#g" \
      "$CONFIG_LOCAL"

}

main "$@"
exit $?
