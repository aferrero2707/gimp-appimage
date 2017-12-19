#! /bin/bash

VER_SUFFIX=""
#VER_SUFFIX="-cce"

PREFIX=app

APP=gimp
LOWERAPP=${APP,,} 

export APPIMAGEBASE=$(pwd)
wget -q https://github.com/probonopd/AppImages/raw/master/functions.sh -O ./functions.sh
. ./functions.sh
#. ./functions-local.sh

#cat_file_from_url https://github.com/probonopd/AppImages/raw/master/excludelist | sed '/^\s*$/d' | sed '/^#.*$/d' > blacklisted

ls -lh
echo "sudo chown -R $USER $APP.AppDir"
sudo chown -R $USER $APP
ls -lh
export APPDIR=$(pwd)/$APP/$APP.AppDir

cd $APP
WD=$(pwd)

export PKG_CONFIG_PATH=$APPDIR/usr/lib/pkgconfig:$PKG_CONFIG_PATH


pwd

#VER1=$(pkg-config --modversion gimp-2.0)-test
#VER1=$(pkg-config --modversion gimp-2.0)-$(date +%Y%m%d)
VER1=$(pkg-config --modversion gimp-2.0)${VER_SUFFIX}-$(date +%Y%m%d)_$(date +%H%M)
if [ x"$FULL_BUNDLING" = "x1" ]; then
    VER1="${VER1}-full"
fi
GLIBC_NEEDED=$(glibc_needed)
#VERSION=$VER1.glibc$GLIBC_NEEDED
VERSION=$VER1
echo $VERSION


echo "Building AppImage..."

ARCH="x86_64"
generate_appimage
#generate_type2_appimage

pwd
ls ../out/*

########################################################################
# Upload the AppDir
########################################################################

transfer ../out/*
echo ""
echo "AppImage has been uploaded to the URL above; use something like GitHub Releases for permanent storage"
