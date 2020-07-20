#! /bin/bash

VER_SUFFIX="$1"
PREFIX=zyx
APP=gimp
LOWERAPP=${APP,,} 
export PATH=/$PREFIX/bin:$PATH
export LD_LIBRARY_PATH=/$PREFIX/lib64:/$PREFIX/lib:$LD_LIBRARY_PATH
export XDG_DATA_DIRS=/$PREFIX/share:$XDG_DATA_DIRS
export PKG_CONFIG_PATH=/$PREFIX/lib/pkgconfig:/$PREFIX/share/pkgconfig:$PKG_CONFIG_PATH


# get some useful helper functions
source /sources/appimage-helper-scripts/functions.sh


# copy the list of libraries that have to be excluded from the bundle
export APPDIR="${APPROOT}/$APP.AppDir"
(rm -rf "${APPDIR}" && mkdir -p "${APPROOT}/$APP.AppDir/usr/bin") || exit 1
cp /sources/appimage-helper-scripts/excludelist "${APPROOT}"


# copy the MIME database
mkdir -p "$APPDIR/usr/share/image"
cp -a /usr/share/mime/image/x-*.xml "$APPDIR/usr/share/image" || exit 1


# run the hook scripts
run_hooks


# build and install zenity
(cd /work && rm -rf zenity && git clone https://github.com/aferrero2707/zenity.git && \
cd zenity && ./autogen.sh && ./configure --prefix=/usr/local && make install && \
cp -a /usr/local/bin/zenity "$APPDIR/usr/bin" && \
cp -a /usr/local/share/zenity "$APPDIR/usr/share" && \
cp /sources/appimage-helper-scripts/zenity.sh "$APPDIR/usr/bin/zenity.sh") || exit 1




# enter the AppImage bundle
cd "$APPDIR" || exit 1


# Copy in the indirect dependencies
# Three runs to ensure we catch indirect ones
copy_deps2 ; copy_deps2 ; copy_deps2 ;


# Remove unneeded libraries
delete_blacklisted2

# Put the gcc libraries in optional folders
copy_gcc_libs


# copy the startup scripts
if [ x"${GTK_VERSION}" = "x3" ]; then
  cp -a /sources/AppRun-v3.sh "$APPDIR/AppRun" || exit 1
else
  cp -a /sources/AppRun.sh "$APPDIR/AppRun" || exit 1
fi

cp /sources/appimage-helper-scripts/apprun-helper.sh "$APPDIR/apprun-helper.sh" || exit 1

# bundle the desktop file and application icon
get_desktop
get_icon


# Workaround for:
# ImportError: /usr/lib/x86_64-linux-gnu/libgdk-x11-2.0.so.0: undefined symbol: XRRGetMonitors
cp $(ldconfig -p | grep libgdk-x11-2.0.so.0 | cut -d ">" -f 2 | xargs) ./usr/lib/
cp $(ldconfig -p | grep libgtk-x11-2.0.so.0 | cut -d ">" -f 2 | xargs) ./usr/lib/


# build and bundle the exec wrapper
# it is used to restore the origin environment when executing
# commands that are outside of the AppImage bundle
source /sources/appimage-helper-scripts/bundle-exec-wrapper.sh || exit 1


# remove debugging symbols for bundled executables and libraries (saves some space)
#strip_binaries


# assemble the version string
echo "GIMP_GIT_TAG = \"$GIMP_GIT_TAG\""
VERSION=""
if [ x"${GTK_VERSION}" = "x3" ]; then
	VERSION=git-$(pkg-config --modversion gimp-3.0)${VER_SUFFIX}-$(date +%Y%m%d)
else
	if [ x"$GIMP_GIT_TAG" = "x" ]; then
		VERSION=git-$(pkg-config --modversion gimp-2.0)${VER_SUFFIX}-$(date +%Y%m%d)
	else
		VERSION=release-$(pkg-config --modversion gimp-2.0)${VER_SUFFIX}
	fi
fi
GLIBC_NEEDED=$(glibc_needed)
echo $VERSION


# cinfigure the desktop integration
get_desktopintegration $LOWERAPP
cp -a "/sources/appimage-helper-scripts/app.wrapper" "$APPDIR/usr/bin/$LOWERAPP.wrapper" || exit 1

echo "ls $APPDIR/usr/share/gimp"
ls $APPDIR/usr/share/gimp


# Go out of AppImage
cd ..

echo "Building AppImage..."
pwd
rm -rf ../out

export ARCH="x86_64"
export NO_GLIBC_VERSION=true
export DOCKER_BUILD=true
mkdir -p /sources/out
generate_type2_appimage
cp -a ../out/*.AppImage /sources/out/GIMP_AppImage-${VERSION}-${ARCH}.AppImage


# do not bundle plugins for 2.99
if [ x"${GTK_VERSION}" = "x3" ]; then exit 0; fi


rm -f /tmp/plugin-list.txt
wget -O /tmp/plugin-list.txt https://raw.githubusercontent.com/aferrero2707/gimp-plugins-collection/check/plugin-list.txt
cat /tmp/plugin-list.txt

mkdir -p "$APPDIR/plug-ins" || exit 1
while IFS='' read -r line || [[ -n "$line" ]]; do
	PLUGIN=${line}
	RELEASE_URL="https://github.com/aferrero2707/gimp-plugins-collection/releases/download/continuous"
	wget -O "/tmp/${PLUGIN}-Gimp-2.10-linux.AppImage" "${RELEASE_URL}/${PLUGIN}-Gimp-2.10-linux.AppImage"
	if [ ! -e "/tmp/${PLUGIN}-Gimp-2.10-linux.AppImage" ]; then continue; fi
	chmod +x "/tmp/${PLUGIN}-Gimp-2.10-linux.AppImage"

	(mkdir -p "/tmp/${PLUGIN}.AppDir" && cd "/tmp/${PLUGIN}.AppDir" && \
	 "/tmp/${PLUGIN}-Gimp-2.10-linux.AppImage" --appimage-extract) || exit 1
	bash "/tmp/${PLUGIN}.AppDir/squashfs-root/AppRun" "$APPDIR/plug-ins"
	
	rm -rf "/tmp/${PLUGIN}.AppDir" "/tmp/${PLUGIN}-Gimp-2.10-linux.AppImage"

done < /tmp/plugin-list.txt

generate_type2_appimage
cp -a ../out/*.AppImage /sources/out/GIMP_AppImage-${VERSION}-withplugins-${ARCH}.AppImage
