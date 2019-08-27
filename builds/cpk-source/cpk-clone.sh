#!/usr/bin/env bash

PARAM_VUFIND_BRANCH="$1"

if [ ! -z "$PARAM_VUFIND_BRANCH" ]; then
    rm -rf "$PARAM_VUFIND_SRC/log"
    echo git clone --depth 1 -b "$PARAM_VUFIND_BRANCH" "https://github.com/moravianlibrary/CPK.git" "$PARAM_VUFIND_SRC"
    git clone --depth 1 -b "$PARAM_VUFIND_BRANCH" "https://github.com/moravianlibrary/CPK.git" "$PARAM_VUFIND_SRC"
    mkdir -p "$PARAM_VUFIND_SRC/log"
    chown www-data:www-data "$PARAM_VUFIND_SRC/log"
    cd "$PARAM_VUFIND_SRC"
    php util/cssBuilder.php
    curl --silent --show-error https://getcomposer.org/installer | php -- --install-dir "${PARAM_VUFIND_SRC}"
fi;
