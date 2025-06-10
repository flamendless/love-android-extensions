#!/usr/bin/env bash

set -euf -o pipefail

GHPATH="${GHPATH:-$HOME/GoingHome}"
ks="ghr.keystore"

checkver () {
    echo "Checking version..."
    local gameversion=$(rg -S "MOBILE_VERSION" ${GHPATH}/game/main.lua -m 1 | cut -d '=' -f 2 | sed -E 's/.*"([0-9]+)d".*/\1/' | xargs)
    local gradleversion=$(rg -S "app.version_code" gradle.properties -m 1 | cut -d '=' -f 2 | xargs)
    echo "Found game version '${gameversion}', gradle version '${gradleversion}'"

    if [ ! "${gameversion}" == "${gradleversion}" ]; then
        echo "Version mismatch. Exiting..."
        exit 1
    fi
}

cplove () {
    set -x
    cp ${GHPATH}/release/GoingHomeRevisited.love app/src/embed/assets/game.love
}

sign_apk () {
    sudo apksigner sign --ks "$ks" app/build/outputs/apk/embedNoRecord/release/app-embed-noRecord-release-unsigned.apk
}

sign_aab () {
    sudo apksigner sign --min-sdk-version 19 --ks "$ks" app/build/outputs/bundle/embedNoRecordRelease/app-embed-noRecord-release.aab
}

apk () {
    set -x
    cplove && sudo ./gradlew assembleEmbedNoRecordRelease && sign_apk
}

aab () {
    set -x
    cplove && sudo ./gradlew bundleEmbedNoRecordRelease && sign_aab
}

if [ "$#" -eq 0 ]; then
    echo "wrong usage"
else
    checkver
    "$1" "$@"
fi
