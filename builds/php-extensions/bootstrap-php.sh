#!/usr/bin/env bash

main() {
    if [ "$PARAM_XDEBUG_ENABLED" == true ]; then
        docker-php-ext-enable xdebug
        cat <<EOF >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
[Xdebug]
xdebug.remote_enable=true
xdebug.remote_host=172.17.0.1
EOF
    fi;
    if [ "$PARAM_AGGRESSIVE_OPCACHE" == true ]; then
        echo "opcache.validate_timestamps=0\n" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini
    fi;
}

main "$@"
exit $?
