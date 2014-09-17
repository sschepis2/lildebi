#!/bin/sh

if [ -z $ANDROID_HOME ]; then
    if [ -e ~/.android/bashrc ]; then
        . ~/.android/bashrc
    else
        echo "ANDROID_HOME must be set!"
        exit
    fi
fi

# standardize timezone to reduce build differences
export TZ=UTC
TIMESTAMP=`git log -n1 --format=format:%ai`

git reset --hard
git clean -fdx
git submodule foreach --recursive git reset --hard
git submodule foreach --recursive git clean -fdx
git submodule sync --recursive
git submodule foreach --recursive git submodule sync
git submodule update --init --recursive

make -C external/ assets

cp ~/.android/ant.properties .

./update-ant-build.sh
faketime -f "@$TIMESTAMP x0.05" ant release

gpg --detach-sign bin/LilDebi-[0-9].*-release.apk
