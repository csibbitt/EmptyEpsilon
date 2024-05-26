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

cd ..
