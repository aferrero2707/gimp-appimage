#! /bin/bash

# Bundle the gobject-introspection runtime
mkdir -p "$APPDIR/usr/lib"
cp -a /usr/lib64/girepository-1.0 "$APPDIR/usr/lib"
cp -a /usr/local/gimp/lib*/girepository-1.0/* "$APPDIR/usr/lib/girepository-1.0"
