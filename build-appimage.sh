#! /bin/bash

export PKG_CONFIG_PATH=/zyx/lib/pkgconfig:/zyx/share/pkgconfig:$PKG_CONFIG_PATH
export ACLOCAL_PATH=/zyx/share/aclocal:$ACLOCAL_PATH

#cp /sources/modulesets/gnome-external-deps-2.32.modules /work/conf/modulesets
cp /sources/modulesets/gimp.modules /work/conf/modulesets

(cd /work && rm -rf libcanberra* && wget http://0pointer.de/lennart/projects/libcanberra/libcanberra-0.30.tar.xz && tar xJvf libcanberra-0.30.tar.xz && cd libcanberra-0.30 && ./configure --prefix=/zyx --enable-gtk-doc=no --enable-gtk-doc-html=no --enable-gtk-doc-pdf=no && make -j 2 && make install && rm -rf libcanberra-0.30) || exit 1

(cd /work && rm -rf mypaint-brushes && git clone -b v1.3.x https://github.com/Jehan/mypaint-brushes && cd mypaint-brushes && ./autogen.sh && ./configure --prefix=/zyx && make && make install && rm -rf mypaint-brushes) || exit 1

#jhbuild -f "/work/conf/gimp.jhbuildrc" -m "/work/conf/modulesets/appimage.modules" --exit-on-error buildone json-glib && \
#jhbuild -f "/work/conf/gimp.jhbuildrc" -m "/work/conf/modulesets/appimage.modules" --exit-on-error buildone poppler-data && \
(jhbuild -f "/work/conf/gimp.jhbuildrc" -m "/work/conf/modulesets/appimage.modules" --exit-on-error buildone babl && \
jhbuild -f "/work/conf/gimp.jhbuildrc" -m "/work/conf/modulesets/appimage.modules" --exit-on-error buildone gegl && \
jhbuild -f "/work/conf/gimp.jhbuildrc" -m "/work/conf/modulesets/appimage.modules" --exit-on-error buildone libmypaint && \
jhbuild -f "/work/conf/gimp.jhbuildrc" -m "/work/conf/modulesets/appimage.modules" --exit-on-error buildone gimp && \
jhbuild -f "/work/conf/gimp.jhbuildrc" -m "/work/conf/modulesets/appimage.modules" --exit-on-error buildone phfgimp && \
jhbuild -f "/work/conf/gimp.jhbuildrc" -m "/work/conf/modulesets/appimage.modules" --exit-on-error buildone resynthesizer && \
jhbuild -f "/work/conf/gimp.jhbuildrc" -m "/work/conf/modulesets/appimage.modules" --exit-on-error buildone gimp-lqr-plugin && \
jhbuild -f "/work/conf/gimp.jhbuildrc" -m "/work/conf/modulesets/appimage.modules" --exit-on-error buildone gtkimageview) || exit 1

cd /work && rm -rf nufraw-* && wget https://sourceforge.net/projects/nufraw/files/nufraw-0.40.tar.gz && tar xzvf nufraw-0.40.tar.gz
cd nufraw-0.40
patch -p1 < /work/conf/modulesets/nufraw-autogen-run-configure.patch
patch -p1 < /work/conf/modulesets/nufraw-register_file_handler_raw.patch
patch -p1 < /work/conf/modulesets/nufraw-fpermissive-flag.patch
(./autogen.sh --prefix=/zyx && make install) || exit 1

bash /sources/mkappimage