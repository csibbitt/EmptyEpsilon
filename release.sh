#!/bin/sh
CSBUILD_TAG=EE-$(grep "VERSION " version.cmake | awk '{print $2}' | sed -e 's/)//')
ORIG_TAG=EE-$(grep "VERSION " version.cmake | awk '{print $2}' | sed -e 's/-.*//')
MAJOR=$(grep MAJOR version.cmake | awk '{print $2}' | sed -e 's/)//')
MINOR=$(grep MINOR version.cmake | awk '{print $2}' | sed -e 's/)//')
PATCH=$(grep PATCH version.cmake | awk '{print $2}' | sed -e 's/)//')
TITLETAG="${MAJOR}${MINOR}${PATCH}"

echo "Forked build w/ 10,000 entry ship's log. This is the ${ORIG_TAG} release with the following additions:

daid/SeriousProton#239
daid#1938" |
gh release create -d -R csibbitt/EmptyEpsilon -F - -t "${TITLETAG}" "${CSBUILD_TAG}" \
'_build_win64/EmptyEpsilon.zip#Windows ZIP' \
'_build_android/EmptyEpsilon-armeabi-v7a.apk#Android arm APK' \
'_build_android_64/EmptyEpsilon-arm64-v8a.apk#Android arm64 APK'