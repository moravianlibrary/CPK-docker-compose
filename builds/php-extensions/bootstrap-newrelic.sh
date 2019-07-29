#!/usr/bin/env bash

main() {
    if [ -n "${NEWRELIC_LICENSE}" -a -n "${NEWRELIC_APPNAME}" ]; then
        mv /usr/local/etc/php/conf.d/newrelic.ini.disabled /usr/local/etc/php/conf.d/newrelic.ini
        echo "newrelic.enabled = true" >> /usr/local/etc/php/conf.d/newrelic.ini
        echo "newrelic.license = \"${NEWRELIC_LICENSE}\"" >> /usr/local/etc/php/conf.d/newrelic.ini
        echo "newrelic.appname = \"${NEWRELIC_APPNAME}\"" >> /usr/local/etc/php/conf.d/newrelic.ini
    fi;
}

main "$@"
