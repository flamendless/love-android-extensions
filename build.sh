#!/usr/bin/env bash

set -euf -o pipefail
set -x

ks="ghr.keystore"

cplove () {
    cp ~/GoingHome/release/GoingHomeRevisited.love app/src/embed/assets/game.love
}

sign_apk () {
    sudo apksigner sign --ks "$ks" app/build/outputs/apk/embedNoRecord/release/app-embed-noRecord-release-unsigned.apk
}

sign_aab () {
    sudo apksigner sign --min-sdk-version 19 --ks "$ks" app/build/outputs/bundle/embedNoRecordRelease/app-embed-noRecord-release.aab
}

apk () {
    cplove && sudo ./gradlew assembleEmbedNoRecordRelease && sign_apk
}

aab () {
    cplove && sudo ./gradlew bundleEmbedNoRecordRelease && sign_aab
}

if [ "$#" -eq 0 ]; then
    echo "wrong usage"
else
    "$1" "$@"
fi
