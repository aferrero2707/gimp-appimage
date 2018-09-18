#! /bin/bash

VER_SUFFIX="$1"
PREFIX=zyx
APP=gimp
LOWERAPP=${APP,,} 
export PATH=/$PREFIX/bin:$PATH
export LD_LIBRARY_PATH=/$PREFIX/lib64:/$PREFIX/lib:$LD_LIBRARY_PATH
export XDG_DATA_DIRS=/$PREFIX/share:$XDG_DATA_DIRS
export PKG_CONFIG_PATH=/$PREFIX/lib/pkgconfig:/$PREFIX/share/pkgconfig:$PKG_CONFIG_PATH


source /sources/appimage-helper-scripts/functions.sh

export APPDIR="${APPROOT}/$APP.AppDir"
(rm -rf "${APPDIR}" && mkdir -p "${APPROOT}/$APP.AppDir/usr/bin") || exit 1
cp /sources/appimage-helper-scripts/excludelist "${APPROOT}"


pwd

#exit


mkdir -p "$APPDIR/usr/share"
cp -a /usr/share/mime "$APPDIR/usr/share"


cd "$APPDIR"


# Bundle GTK2 stuff
/sources/appimage-helper-scripts/bundle-gtk2.sh

# Bundle python
/sources/appimage-helper-scripts/bundle-python.sh


run_hooks

#exit

# manually copy libssl, as it seems not to be picked by the copy_deps function
#cp -L /lib/x86_64-linux-gnu/libssl.so.1.0.0 ./usr/lib


# Copy in the indirect dependencies
# Three runs to ensure we catch indirect ones
copy_deps2 ; copy_deps2 ; copy_deps2 ;



cp -a /sources/AppRun.sh ./AppRun
cp /sources/appimage-helper-scripts/apprun-helper.sh ./apprun-helper.sh
get_desktop
get_icon


# Remove unneeded libraries
delete_blacklisted2

# Put the gcc libraries in optional folders
copy_gcc_libs


# Workaround for:
# GLib-GIO-ERROR **: Settings schema 'org.gtk.Settings.FileChooser' is not installed
# when trying to use the file open dialog
# AppRun exports usr/share/glib-2.0/schemas/ which might be hurting us here
#( mkdir -p usr/share/glib-2.0/schemas/ ; cd usr/share/glib-2.0/schemas/ ; ln -s /usr/share/glib-2.0/schemas/gschemas.compiled . )

# Workaround for:
# ImportError: /usr/lib/x86_64-linux-gnu/libgdk-x11-2.0.so.0: undefined symbol: XRRGetMonitors
cp $(ldconfig -p | grep libgdk-x11-2.0.so.0 | cut -d ">" -f 2 | xargs) ./usr/lib/
cp $(ldconfig -p | grep libgtk-x11-2.0.so.0 | cut -d ">" -f 2 | xargs) ./usr/lib/

appdir=$(pwd)
echo "appdir: $appdir"

(rm -rf /work/appimage-exec-wrapper2 && \
cp -a /sources/appimage-helper-scripts/appimage-exec-wrapper2 /work && \
cd /work/appimage-exec-wrapper2 && make && \
cp -a exec.so $APPDIR/usr/lib/exec_wrapper2.so) || exit 1
#read dummy


# Package BABL/GEGL/GIMP header and pkg-config files, 
# so that the AppImage can be used to compile plug-ins
mkdir "$APPDIR/usr/include"
mkdir "$APPDIR/usr/lib/pkgconfig"
for dir in babl gegl gimp; do
  cp -a "${GIMP_REFIX}/include/${dir}-"* "$APPDIR/usr/include"
  cp -a "${GIMP_REFIX}/lib/pkgconfig/${dir}-"*.pc "$APPDIR/usr/lib/pkgconfig"
done

strip_binaries



#VER1=$(pkg-config --modversion gimp-2.0)-test
#VER1=$(pkg-config --modversion gimp-2.0)-$(date +%Y%m%d)
echo "GIMP_GIT_TAG = \"$GIMP_GIT_TAG\""
if [ x"$GIMP_GIT_TAG" = "x" ]; then
	VER1=git-$(pkg-config --modversion gimp-2.0)${VER_SUFFIX}-$(date +%Y%m%d)
else
	VER1=release-$(pkg-config --modversion gimp-2.0)${VER_SUFFIX}
fi
if [ x"$FULL_BUNDLING" = "x1" ]; then
    VER1="${VER1}-full"
fi
GLIBC_NEEDED=$(glibc_needed)
#VERSION=$VER1.glibc$GLIBC_NEEDED
VERSION=$VER1
echo $VERSION

get_desktopintegration $LOWERAPP
#cp -a ../../$LOWERAPP.wrapper ./usr/bin/$LOWERAPP.wrapper
#cp -a ../../desktopintegration ./usr/bin/$LOWERAPP.wrapper
#chmod a+x ./usr/bin/$LOWERAPP.wrapper
#sed -i -e "s|Exec=$LOWERAPP|Exec=$LOWERAPP.wrapper|g" $LOWERAPP.desktop

#exit

# Go out of AppImage
cd ..

echo "Building AppImage..."
pwd
rm -rf ../out

export ARCH="x86_64"
export NO_GLIBC_VERSION=true
export DOCKER_BUILD=true
#generate_appimage
generate_type2_appimage

mkdir -p /sources/out
cp -a ../out/*.AppImage /sources/out/GIMP_AppImage-${VERSION}-${ARCH}.AppImage