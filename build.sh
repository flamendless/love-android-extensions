#!/usr/bin/env bash

set -euf -o pipefail

GHPATH="${GHPATH:-$HOME/GoingHome}"
ks="ghr.keystore"

checkver () {
    echo "Checking version..."
    local gameversion=$(rg -S "VERSION" ${GHPATH}/game/main.lua -m 1 | cut -d '=' -f 2 | sed -E 's/\r//g' | xargs)
    local apkversion=$(rg -S "app.version_name" gradle.properties -m 1 | cut -d '=' -f 2 | xargs)
    echo "Found game version '${gameversion}', gradle version 'v${apkversion}'"

    if [ ! "${gameversion}" == "v${apkversion}" ]; then
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
