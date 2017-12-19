#! /bin/bash

export PKG_CONFIG_PATH=/app/share/pkgconfig:$PKG_CONFIG_PATH
export ACLOCAL_PATH=/app/share/aclocal:$ACLOCAL_PATH

cp /sources/modulesets/gnome-external-deps-2.32.modules /work/conf/modulesets

#jhbuild -f "/sources/gimp.jhbuildrc" -m "/work/conf/modulesets/gimp.modules" --exit-on-error buildone json-glib && \
#jhbuild -f "/sources/gimp.jhbuildrc" -m "/work/conf/modulesets/gimp.modules" --exit-on-error buildone poppler-data && \
(jhbuild -f "/sources/gimp.jhbuildrc" -m "/work/conf/modulesets/appimage.modules" --exit-on-error buildone babl && \
jhbuild -f "/sources/gimp.jhbuildrc" -m "/work/conf/modulesets/appimage.modules" --exit-on-error buildone gegl && \
jhbuild -f "/sources/gimp.jhbuildrc" -m "/work/conf/modulesets/appimage.modules" --exit-on-error buildone libmypaint && \
jhbuild -f "/sources/gimp.jhbuildrc" -m "/work/conf/modulesets/appimage.modules" --exit-on-error buildone gimp && \
jhbuild -f "/sources/gimp.jhbuildrc" -m "/work/conf/modulesets/appimage.modules" --exit-on-error buildone phfgimp && \
#jhbuild -f "/sources/gimp.jhbuildrc" -m "/work/conf/modulesets/appimage.modules" --exit-on-error buildone resynthesizer && \
jhbuild -f "/sources/gimp.jhbuildrc" -m "/work/conf/modulesets/appimage.modules" --exit-on-error buildone gimp-lqr-plugin && \
jhbuild -f "/sources/gimp.jhbuildrc" -m "/work/conf/modulesets/gimp.modules" --exit-on-error buildone gtkimageview) || exit 1

cd /work && rm -rf nufraw-* && wget https://sourceforge.net/projects/nufraw/files/nufraw-0.40.tar.gz && tar xzvf nufraw-0.40.tar.gz
cd nufraw-0.40
patch -p1 < /work/conf/modulesets/nufraw-autogen-run-configure.patch
patch -p1 < /work/conf/modulesets/nufraw-register_file_handler_raw.patch
patch -p1 < /work/conf/modulesets/nufraw-fpermissive-flag.patch
(./autogen.sh --prefix=/app && make install) || exit 1

bash /sources/mkappimage