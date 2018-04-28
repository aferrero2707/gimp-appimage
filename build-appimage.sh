#! /bin/bash

export PKG_CONFIG_PATH=/zyx/lib/pkgconfig:/zyx/share/pkgconfig:$PKG_CONFIG_PATH
export ACLOCAL_PATH=/zyx/share/aclocal:$ACLOCAL_PATH

cp /sources/modulesets/gnome-external-deps-2.32.modules /work/conf/modulesets
cp /sources/modulesets/gimp.modules /work/conf/modulesets
#cp /sources/modulesets/appimage.modules /work/conf/modulesets

if [ x"$BABL_GIT_TAG" = "x" ]; then
	sed -i -e "s/BABL_GIT_TAG/master/g" /work/conf/modulesets/gimp.modules
else
	sed -i -e "s/BABL_GIT_TAG/$BABL_GIT_TAG/g" /work/conf/modulesets/gimp.modules
fi

if [ x"$GEGL_GIT_TAG" = "x" ]; then
	sed -i -e "s/GEGL_GIT_TAG/master/g" /work/conf/modulesets/gimp.modules
else
	sed -i -e "s/GEGL_GIT_TAG/$GEGL_GIT_TAG/g" /work/conf/modulesets/gimp.modules
fi

if [ x"$GIMP_GIT_TAG" = "x" ]; then
	sed -i -e "s/GIMP_GIT_TAG/master/g" /work/conf/modulesets/gimp.modules
else
	sed -i -e "s/GIMP_GIT_TAG/$GIMP_GIT_TAG/g" /work/conf/modulesets/gimp.modules
fi

(cd /work && rm -rf libcanberra* && wget http://0pointer.de/lennart/projects/libcanberra/libcanberra-0.30.tar.xz && tar xJvf libcanberra-0.30.tar.xz && cd libcanberra-0.30 && ./configure --prefix=/zyx --enable-gtk-doc=no --enable-gtk-doc-html=no --enable-gtk-doc-pdf=no && make -j 2 && make install && rm -rf libcanberra-0.30) || exit 1

(cd /work && rm -rf mypaint-brushes && git clone -b v1.3.x https://github.com/Jehan/mypaint-brushes && cd mypaint-brushes && ./autogen.sh && ./configure --prefix=/zyx && make && make install && rm -rf mypaint-brushes) || exit 1

apt-get install -y libsuitesparse-dev || exit 1

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

apt-get install -y qtbase5-dev qttools5-dev wget
(cd /work && rm -rf gmic gmic-qt && \
git clone https://github.com/dtschump/gmic.git && git clone https://github.com/c-koi/gmic-qt.git && \
make -C gmic/src CImg.h gmic_stdlib.h && cd gmic-qt && mkdir -p build && cd build && \
cmake .. -DGMIC_QT_HOST=gimp -DCMAKE_BUILD_TYPE=Release && make) || exit 1

gimplibdir=$(pkg-config --variable=gimplibdir gimp-2.0)
echo "gimplibdir: $gimplibdir"
if [ -z "$gimplibdir" ]; then exit 1; fi

cp -a /work/gmic-qt/build/gmic_gimp_qt "$gimplibdir/plug-ins"

bash /sources/mkappimage
