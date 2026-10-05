#!/bin/sh
xcodebuild -scheme AoC2020 -configuration Release SYMROOT="$PWD/build"
time ./build/Release/AoC2020