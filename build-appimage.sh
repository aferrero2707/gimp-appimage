#! /bin/bash

export PKG_CONFIG_PATH=/app/share/pkgconfig:$PKG_CONFIG_PATH
export ACLOCAL_PATH=/app/share/aclocal:$ACLOCAL_PATH

cp /sources/modulesets/gnome-external-deps-2.32.modules /work/conf/modulesets

#jhbuild -f "/sources/gimp.jhbuildrc" -m "/work/conf/modulesets/gimp.modules" --exit-on-error buildone json-glib && \
#jhbuild -f "/sources/gimp.jhbuildrc" -m "/work/conf/modulesets/gimp.modules" --exit-on-error buildone poppler-data && \
jhbuild -f "/sources/gimp.jhbuildrc" -m "/work/conf/modulesets/appimage.modules" --exit-on-error buildone babl && \
jhbuild -f "/sources/gimp.jhbuildrc" -m "/work/conf/modulesets/appimage.modules" --exit-on-error buildone gegl && \
jhbuild -f "/sources/gimp.jhbuildrc" -m "/work/conf/modulesets/appimage.modules" --exit-on-error buildone libmypaint && \
jhbuild -f "/sources/gimp.jhbuildrc" -m "/work/conf/modulesets/appimage.modules" --exit-on-error buildone gimp && \
jhbuild -f "/sources/gimp.jhbuildrc" -m "/work/conf/modulesets/appimage.modules" --exit-on-error buildone phfgimp && \
jhbuild -f "/sources/gimp.jhbuildrc" -m "/work/conf/modulesets/appimage.modules" --exit-on-error buildone resynthesizer && \
jhbuild -f "/sources/gimp.jhbuildrc" -m "/work/conf/modulesets/appimage.modules" --exit-on-error buildone gimp-lqr-plugin
#jhbuild -f "/sources/gimp.jhbuildrc" -m "/work/conf/modulesets/gimp.modules" --exit-on-error buildone nufraw && \
