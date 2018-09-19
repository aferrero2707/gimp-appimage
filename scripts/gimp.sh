#! /bin/bash

pwd

# Copy executable, icon and desktop file
GIMP_PREFIX=$(pkg-config --variable=prefix gimp-2.0)
if [ x"${GIMP_PREFIX}" = "x" ]; then
	echo "Could not determine GIMP installation prefix, exiting."
	exit 1
fi

echo "Copying GIMP executable and desktop file"
echo "GIMP_PREFIX: ${GIMP_PREFIX}"
cp -a ${GIMP_PREFIX}/bin/gimp* "$APPDIR/usr/bin" || exit 1
GIMP_EXE_NAME=$(cat ${GIMP_PREFIX}/share/applications/gimp.desktop | grep "^Exec=" | cut -d"=" -f 2 | cut -d" " -f 1)
rm -f usr/bin/$LOWERAPP.bin
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

# Copy the GIMP python interpreter configuration
(mkdir -p "$APPDIR/usr/lib/gimp" && \
cp -a ${GIMP_PREFIX}/lib/gimp/2.0 "$APPDIR/usr/lib/gimp") || exit 1

(mkdir -p "$APPDIR/usr/share/gimp" && \
cp -a ${GIMP_PREFIX}/share/gimp/2.0 "$APPDIR/usr/share/gimp") || exit 1

(mkdir -p "$APPDIR/usr/etc/gimp" && \
cp -a ${GIMP_PREFIX}/etc/gimp/2.0 "$APPDIR/usr/etc/gimp") || exit 1

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
