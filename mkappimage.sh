#! /bin/bash

bash /sources/build-appimage-centos7.sh || exit 1
bash /sources/package-appimage.sh || exit 1

bash /sources/build-appimage-plugins-centos7.sh || exit 1
bash /sources/package-appimage.sh "-withplugins" || exit 1
