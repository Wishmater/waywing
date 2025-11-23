#!/bin/sh
set -x

# Set default build type to release
BUILD_TYPE="release"

# Parse build type
while [ $# -gt 0 ]; do
    case "$1" in
        --release)
            BUILD_TYPE="release"
            shift
            ;;
        --profile)
            BUILD_TYPE="profile"
            shift
            ;;
        --debug)
            BUILD_TYPE="debug"
            shift
            ;;
        *)
            # Preserve all other arguments for appimagetool
            break
            ;;
    esac
done

APPIMAGETOOL=""
if ! type appimagetool > /dev/null; then
    ARCH="$(uname -m)"
    # shellcheck disable=SC2210
    wget https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-"$ARCH".AppImage > /dev/null 2>1
    chmod +x appimagetool-"$ARCH".AppImage
    APPIMAGETOOL="$PWD/appimagetool-$ARCH.AppImage"
else
    APPIMAGETOOL=$(which appimagetool)
fi

echo "appimagetoo located in $APPIMAGETOOL"

rm -rf AppDir
cp -r build/linux/x64/$BUILD_TYPE/bundle AppDir
mv AppDir/waywing AppDir/AppRun
cp linux/waywing.desktop AppDir
cp linux/waywing.svg AppDir

$APPIMAGETOOL AppDir "$@"
