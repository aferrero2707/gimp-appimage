#! /bin/bash

# Copy Qt5 plugins
QT5PLUGINDIR=$(pkg-config --variable=plugindir Qt5)
if [ x"$QT5PLUGINDIR" != "x" ]; then
  mkdir -p "$APPDIR/usr/lib/qt5/plugins"
  cp -a "$QT5PLUGINDIR"/* "$APPDIR/usr/lib/qt5/plugins"
fi

(mkdir -p "$APPDIR/startup_scripts" && \
cp -a /sources/startup_scripts/gmic.sh "$APPDIR/startup_scripts") || exit 1