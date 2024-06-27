#!/bin/sh
set -e

rm -Rf _build
mkdir _build
cd _build
cmake .. -G Ninja -DSERIOUS_PROTON_DIR=$PWD/../../SeriousProton/ -DCMAKE_PROJECT_EmptyEpsilon_INCLUDE=./version.cmake
ninja

cd ..

rm -Rf _build_win32
mkdir _build_win32
cd _build_win32
cmake .. -G Ninja -DCMAKE_TOOLCHAIN_FILE=../cmake/mingw.toolchain -DSERIOUS_PROTON_DIR=../../SeriousProton -DCMAKE_PROJECT_EmptyEpsilon_INCLUDE=./version.cmake
ninja
ninja package

cd ..

rm -Rf _build_android
mkdir _build_android
cd _build_android
cmake .. -G Ninja -DSERIOUS_PROTON_DIR=../../SeriousProton -DCMAKE_TOOLCHAIN_FILE=../cmake/android.toolchain -DCMAKE_PROJECT_EmptyEpsilon_INCLUDE=./version.cmake
ninja

cd ..

rm -Rf _build_android_64
mkdir _build_android_64
cd _build_android_64
cmake .. -G Ninja -DSERIOUS_PROTON_DIR=../../SeriousProton -DCMAKE_TOOLCHAIN_FILE=../cmake/android.toolchain -DANDROID_ABI=arm64-v8a  -DCMAKE_PROJECT_EmptyEpsilon_INCLUDE=./version.cmake
ninja

cd ..
