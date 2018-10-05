#!/usr/bin/env bash

export PATH="$APPDIR/usr/bin:${PATH}:/sbin:/usr/sbin"
export LD_LIBRARY_PATH="$AILIBDIR:/usr/lib:$LD_LIBRARY_PATH"
export XDG_DATA_DIRS="${APPDIR}/usr/share/:${XDG_DATA_DIRS}:/usr/local/share/:/usr/share/"
export ZENITY_DATA_DIR="$APPDIR/usr/share/zenity"

export GTK_PATH="${APPDIR}/usr/lib/gtk-2.0:${GTK_PATH}"
export PANGO_LIBDIR="${APPDIR}/usr/lib"
export GCONV_PATH="${APPDIR}/usr/lib/gconv"
export GDK_PIXBUF_MODULEDIR="${APPDIR}/usr/lib/gdk-pixbuf-2.0/loaders"
export GDK_PIXBUF_MODULE_FILE="${APPDIR}/usr/lib/gdk-pixbuf-2.0/loaders.cache"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$GDK_PIXBUF_MODULEDIR"

if [ "x" = "y" ]; then
mkdir -p "$AILIBDIR/gdk-pixbuf-2.0"
cp "${APPDIR}/usr/lib/gdk-pixbuf-2.0/loaders.cache" "$AILIBDIR/gdk-pixbuf-2.0"
sed -i -e "s|LOADERSDIR|${APPDIR}/usr/lib/gdk-pixbuf-2.0/loaders|g" "$AILIBDIR/gdk-pixbuf-2.0/loaders.cache"
export GDK_PIXBUF_MODULE_FILE="$AILIBDIR/gdk-pixbuf-2.0/loaders.cache"
fi

"$APPDIR/usr/bin/zenity" "$@"  --no-wrap