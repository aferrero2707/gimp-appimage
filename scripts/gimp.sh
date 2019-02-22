#! /bin/bash

pwd

export GIMPPREFIX=/usr/local/gimp
export PKG_CONFIG_PATH=${GIMPPREFIX}/lib64/pkgconfig:${GIMPPREFIX}/lib/pkgconfig:${GIMPPREFIX}/share/pkgconfig:$PKG_CONFIG_PATH
export ACLOCAL_PATH=${GIMPPREFIX}/share/aclocal:$ACLOCAL_PATH
export LD_LIBRARY_PATH=${GIMPPREFIX}/lib64:${GIMPPREFIX}/lib:$LD_LIBRARY_PATH
export PATH=${GIMPPREFIX}/bin:$PATH


# Copy executable, icon and desktop file
if [ x"${GTK_VERSION}" = "x3" ]; then
	GIMP_PREFIX=$(pkg-config --variable=prefix gimp-3.0)
else
	GIMP_PREFIX=$(pkg-config --variable=prefix gimp-2.0)
fi
if [ x"${GIMP_PREFIX}" = "x" ]; then
	echo "Could not determine GIMP installation prefix, exiting."
	exit 1
fi

echo "Copying GIMP executable and desktop file"
echo "GIMP_PREFIX: ${GIMP_PREFIX}"
cp -a ${GIMP_PREFIX}/bin/gimp* "$APPDIR/usr/bin" || exit 1
GIMP_EXE_NAME=$(cat ${GIMP_PREFIX}/share/applications/gimp.desktop | grep "^Exec=" | cut -d"=" -f 2 | cut -d" " -f 1)
(cd "$APPDIR/usr/bin" && rm -f $LOWERAPP.bin && ln -s ${GIMP_EXE_NAME} $LOWERAPP.bin) || exit 1

(mkdir -p "$APPDIR/usr/share" && cp -a ${GIMP_PREFIX}/share/$LOWERAPP "$APPDIR/usr/share") || exit 1
(mkdir -p "$APPDIR/usr/share/applications" && cp ${GIMP_PREFIX}/share/applications/$LOWERAPP.desktop "$APPDIR/usr/share/applications") || exit 1

echo "Copying GIMP icon"
pwd
WD="$(pwd)"
cd ${GIMP_PREFIX}/share/icons/hicolor
pwd
for f in *; do
  echo "f: \"$f\""
  ls $f/apps/$LOWERAPP.png
  if [ -e $f/apps/$LOWERAPP.png ]; then
    mkdir -p "$APPDIR/usr/share/icons/hicolor/$f/apps" || exit 1
    cp $f/apps/$LOWERAPP.png "$APPDIR/usr/share/icons/hicolor/$f/apps" || exit 1
  fi
done
cd "$WD"
pwd

echo "ls ${GIMP_PREFIX}/lib/gimp/"
ls ${GIMP_PREFIX}/lib/gimp/

# Copy the GIMP python interpreter configuration
(mkdir -p "$APPDIR/usr/lib/gimp" && \
cp -a ${GIMP_PREFIX}/lib/gimp/?.*/* "$APPDIR/usr/lib/gimp") || exit 1
echo "ls $APPDIR/usr/lib/gimp"
ls $APPDIR/usr/lib/gimp

(mkdir -p "$APPDIR/usr/share/locale" && \
cp -a ${GIMP_PREFIX}/share/locale/* "$APPDIR/usr/share/locale") || exit 1
echo "ls $APPDIR/usr/share/locale"
ls $APPDIR/usr/share/locale

(mkdir -p "$APPDIR/usr/share/gimp" && \
cp -a ${GIMP_PREFIX}/share/gimp/?.*/* "$APPDIR/usr/share/gimp") || exit 1
echo "ls $APPDIR/usr/share/gimp"
ls $APPDIR/usr/lshare/gimp

(mkdir -p "$APPDIR/usr/etc/gimp" && \
cp -a ${GIMP_PREFIX}/etc/gimp/?.*/* "$APPDIR/usr/etc/gimp") || exit 1
echo "ls $APPDIR/usr/etc/gimp"
ls $APPDIR/usr/etc/gimp

BABL_LIBDIR=$(pkg-config --variable=libdir babl)
if [ x"${BABL_LIBDIR}" = "x" ]; then
  echo "Cannot determine BABL libdir, exiting"; exit 1;
fi
cp -a "${BABL_LIBDIR}/babl-0.1" "$APPDIR/usr/lib"

GEGL_PLUGDIR=$(pkg-config --variable=pluginsdir gegl-0.4)
if [ x"${GEGL_PLUGDIR}" = "x" ]; then
  echo "Cannot determine GEGL pluginsdir, exiting"; exit 1;
fi
cp -a "${GEGL_PLUGDIR}" "$APPDIR/usr/lib"



# Package BABL/GEGL/GIMP header and pkg-config files, 
# so that the AppImage can be used to compile plug-ins
mkdir "$APPDIR/usr/include"
mkdir "$APPDIR/usr/lib/pkgconfig"
for dir in babl gegl gimp; do
  cp -a "${GIMP_PREFIX}/include/${dir}"* "$APPDIR/usr/include"
  cp -a "${GIMP_PREFIX}/lib/pkgconfig/${dir}"*.pc "$APPDIR/usr/lib/pkgconfig"
done

