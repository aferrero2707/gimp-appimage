#! /bin/bash

export QT_PLUGIN_PATH="$APPDIR/usr/lib/qt5/plugins":$QT_PLUGIN_PATH

#if [ ! -e /etc/pki/nssdb ]; then
#	echo "Setting SSL_DIR=$APPDIR/usr/etc/pki/nssdb"
#	export SSL_DIR="$APPDIR/usr/etc/pki/nssdb"
#fi