#!/usr/bin/env bash

main() {
    if [ "$PARAM_XDEBUG_ENABLED" == true ]; then
        docker-php-ext-enable xdebug
        cat <<EOF >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
[Xdebug]
xdebug.remote_enable=true
xdebug.remote_host=$PARAM_XDEBUG_REMOTE_HOST
EOF
        if [ ! -z "$PARAM_XDEBUG_PROFILER_TRIGGER_VALUE" ]; then
            PROFILER_OUTPUT_DIRECTORY="/var/www/cpk/profiler"
            if [ ! -d "$PROFILER_OUTPUT_DIRECTORY" ]; then
                mkdir "$PROFILER_OUTPUT_DIRECTORY"
                chown www-data:www-data "$PROFILER_OUTPUT_DIRECTORY"
            fi;
            echo "xdebug.profiler_enable=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
            echo "xdebug.profiler_enable_trigger=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
            echo "xdebug.profiler_enable_trigger_value=$PARAM_XDEBUG_PROFILER_TRIGGER_VALUE" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
            echo "xdebug.profiler_output_dir=/var/www/cpk/profiler" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
        fi;
    fi;
    if [ "$PARAM_AGGRESSIVE_OPCACHE" == true ]; then
        echo "opcache.validate_timestamps=0" >> /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini
    fi;
}

main "$@"
exit $?
