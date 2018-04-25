#!/usr/bin/env bash

main() {
    if [ "$PARAM_XDEBUG_ENABLED" == true ]; then
        docker-php-ext-enable xdebug
    fi;
}

main "$@"
exit $?
