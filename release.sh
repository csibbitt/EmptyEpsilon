#!/bin/sh
CSBUILD_TAG=EE-$(grep "VERSION " version.cmake | awk '{print $2}' | sed -e 's/)//')
ORIG_TAG=EE-$(grep "VERSION " version.cmake | awk '{print $2}' | sed -e 's/-.*//')
MAJOR=$(grep MAJOR version.cmake | awk '{print $2}' | sed -e 's/)//')
MINOR=$(grep MINOR version.cmake | awk '{print $2}' | sed -e 's/)//')
PATCH=$(grep PATCH version.cmake | awk '{print $2}' | sed -e 's/)//')
TITLETAG="${MAJOR}${MINOR}${PATCH}"

echo "Forked build w/ support for very large maps. This is the ${ORIG_TAG} release with the following additions:

* Larger zoom limits on Relay, Spectator, and GM screens (https://github.com/csibbitt/EmptyEpsilon/commit/6bfbc37)
* Relay Button to center on ship (daid#2298 - https://github.com/csibbitt/EmptyEpsilon/commit/f3484d3)
* Three-letter sector names for huge maps (https://github.com/csibbitt/EmptyEpsilon/commit/ad259acd)
" |
gh release create -d -R csibbitt/EmptyEpsilon -F - -t "${TITLETAG}" "${CSBUILD_TAG}" \
'_build_win64/EmptyEpsilon.zip#Windows ZIP' \
'_build_android/EmptyEpsilon-armeabi-v7a.apk#Android arm APK' \
'_build_android_64/EmptyEpsilon-arm64-v8a.apk#Android arm64 APK'
