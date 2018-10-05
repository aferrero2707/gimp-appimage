#! /bin/bash

# build and bundle the exec wrapper
# it is used to restore the origin environment when executing
# commands that are outside of the AppImage bundle
(rm -rf /tmp/appimage-exec-wrapper2 && \
cp -a /sources/appimage-helper-scripts/appimage-exec-wrapper2 /tmp && \
cd /tmp/appimage-exec-wrapper2 && make && \
cp -a exec.so "$APPDIR/usr/lib/exec_wrapper.so") || exit 1
