#! /bin/bash

bash /sources/build-appimage.sh || exit 1

export APPROOT=/work/appimage
(mkdir -p "${APPROOT}/scripts" && cp -a /sources/scripts/gimp.sh "${APPROOT}/scripts") || exit 1
bash /sources/package-appimage.sh || exit 1

(mkdir -p "${APPROOT}/scripts" && cp -a /sources/scripts/gmic.sh "${APPROOT}/scripts") || exit 1
bash /sources/build-appimage-plugins.sh || exit 1
bash /sources/package-appimage.sh "-withplugins" || exit 1
