#! /bin/bash

bash /sources/build-appimage.sh || exit 1

export APPROOT=/work/appimage

# copy hook scripts
(mkdir -p "${APPROOT}/scripts" && \
cp -a /sources/scripts/gimp.sh "${APPROOT}/scripts" && \
cp -a /sources/appimage-helper-scripts/bundle-gtk2.sh "${APPROOT}/scripts" &&
cp -a /sources/appimage-helper-scripts/bundle-python.sh "${APPROOT}/scripts") || exit 1

# fill and package the AppImage bundle
bash /sources/package-appimage.sh || exit 1
exit

(mkdir -p "${APPROOT}/scripts" && cp -a /sources/scripts/gmic.sh "${APPROOT}/scripts") || exit 1
bash /sources/build-appimage-plugins.sh || exit 1
bash /sources/package-appimage.sh "-withplugins" || exit 1
