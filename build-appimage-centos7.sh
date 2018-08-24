#! /bin/bash

export PKG_CONFIG_PATH=/zyx/lib64/pkgconfig:/zyx/lib/pkgconfig:/zyx/share/pkgconfig:$PKG_CONFIG_PATH
export ACLOCAL_PATH=/zyx/share/aclocal:$ACLOCAL_PATH
export LD_LIBRARY_PATH=/zyx/lib64:/zyx/lib:$LD_LIBRARY_PATH

(yum update -y && yum install -y epel-release && yum update -y && yum install -y libtool-ltdl-devel autoconf automake libtools which json-c-devel json-glib-devel gtk-doc gperf libuuid-devel libcroco-devel python-devel python-pip nano) || exit 1


DO_BUILD=1
if [ x"$DO_BUILD" = "x1" ]; then


if [ ! -e /work/lcms2-2.9 ]; then
  (cd /work && rm -rf lcms2* && wget https://sourceforge.net/projects/lcms/files/lcms/2.9/lcms2-2.9.tar.gz && tar xvf lcms2-2.9.tar.gz && cd lcms2-2.9 && ./configure --prefix=/zyx && make install) || exit 1
fi


if [ ! -e /work/libpng-1.6.35 ]; then
  (cd /work && rm -rf libpng* && wget https://sourceforge.net/projects/libpng/files/libpng16/1.6.35/libpng-1.6.35.tar.xz && tar xvf libpng-1.6.35.tar.xz && cd libpng-1.6.35 && ./configure --prefix=/zyx && make -j 2 install) || exit 1
fi

if [ ! -e /work/freetype-2.9.1 ]; then
(cd /work && rm -rf freetype* && wget https://download.savannah.gnu.org/releases/freetype/freetype-2.9.1.tar.bz2 && tar xvf freetype-2.9.1.tar.bz2 && cd freetype-2.9.1 && ./configure --prefix=/zyx && make -j 2 install) || exit 1
fi


if [ ! -e /work/fontconfig-2.13.0 ]; then
  (cd /work && rm -rf fontconfig* && wget https://www.freedesktop.org/software/fontconfig/release/fontconfig-2.13.0.tar.bz2 && tar xvf fontconfig-2.13.0.tar.bz2 && cd fontconfig-2.13.0 && ./configure --prefix=/zyx --disable-docs && make -j 2 install) || exit 1
fi


#  (cd /work && rm -rf glib* && git clone -b glib-2-56 https://gitlab.gnome.org/GNOME/glib.git && cd glib && ./autogen.sh --prefix=/zyx && make -j 2 install) || exit 1
#  exit


if [ ! -e /work/exiv2-trunk ]; then
  (cd /work && rm -rf exiv2* && wget http://www.exiv2.org/builds/exiv2-0.26-trunk.tar.gz && tar xvf exiv2-0.26-trunk.tar.gz && cd exiv2-trunk && mkdir -p build && cd build && cmake -DCMAKE_INSTALL_PREFIX=/zyx .. && make -j 2 install) || exit 1
  cp -a /zyx/lib64/libexiv2.so* /zyx/lib
fi


if [ ! -e /work/cairo-1.15.12 ]; then
  (cd /work && rm -rf cairo* && wget https://www.cairographics.org/snapshots/cairo-1.15.12.tar.xz && tar xvf cairo-1.15.12.tar.xz && cd cairo-1.15.12 && ./configure --prefix=/zyx && make -j 2 install) || exit 1
fi

#export PYTHONPATH=/zyx/lib64/python2.7/site-packages/:$PYTHONPATH

pip install pycairo
#if [ ! -e /work/pycairo-1.17.1 ]; then
#  (cd /work && rm -rf pycairo* && wget https://github.com/pygobject/pycairo/releases/download/v1.17.1/pycairo-1.17.1.tar.gz && tar xvf pycairo-1.17.1.tar.gz && cd pycairo-1.17.1) || exit 1
#  exit
#fi


if [ ! -e /work/librsvg ]; then
  curl https://sh.rustup.rs -sSf > /r.sh && bash /r.sh -y
  export PATH=$HOME/.cargo/bin:$PATH
  (cd /work && rm -rf librsvg* && git clone -b librsvg-2.42 https://gitlab.gnome.org/GNOME/librsvg.git && cd librsvg && ./autogen.sh --prefix=/zyx && make -j 2 install) || exit 1
fi


if [ ! -e /work/poppler-0.68.0 ]; then
(cd /work && rm -rf poppler-data* && wget https://poppler.freedesktop.org/poppler-data-0.4.9.tar.gz && tar xvf poppler-data-0.4.9.tar.gz && cd poppler-data-0.4.9 && mkdir -p build && cd  build && FREETYPE_DIR=/zyx cmake -DCMAKE_INSTALL_PREFIX=/zyx .. && make VERBOSE=1 -j 1 install) || exit 1
(cd /work && rm -rf poppler-0.* && wget https://poppler.freedesktop.org/poppler-0.68.0.tar.xz && tar xvf poppler-0.68.0.tar.xz && cd poppler-0.68.0 && mkdir -p build && cd  build && FREETYPE_DIR=/zyx cmake -DCMAKE_INSTALL_PREFIX=/zyx -DENABLE_LIBOPENJPEG=none .. && make VERBOSE=1 -j 1 install) || exit 1
#(cd /work/poppler-0.68.0 && rm -rf build && mkdir -p build && cd  build && FREETYPE_DIR=/zyx cmake -DCMAKE_INSTALL_PREFIX=/zyx -DENABLE_LIBOPENJPEG=none ..) || exit 1
fi


#pip install pygobject
#pip install pygtk
if [ ! -e /work/pygobject-2.28.7 ]; then
  (cd /work && rm -rf pygobject*  && wget https://ftp.acc.umu.se/pub/GNOME/sources/pygobject/2.28/pygobject-2.28.7.tar.xz && tar xvf pygobject-2.28.7.tar.xz && cd pygobject-2.28.7 && ./configure --prefix=/usr && make install) || exit 1
fi
if [ ! -e /work/pygtk-2.24.0 ]; then
  (cd /work && rm -rf pygtk* && wget https://ftp.acc.umu.se/pub/GNOME/sources/pygtk/2.24/pygtk-2.24.0.tar.bz2 && tar xvf pygtk-2.24.0.tar.bz2 && cd pygtk-2.24.0 && ./configure --prefix=/usr && make install) || exit 1
  #exit
fi

if [ ! -e /work/gexiv2-0.10.8 ]; then
  (cd /work && rm -rf gexiv2* && wget https://download.gnome.org/sources/gexiv2/0.10/gexiv2-0.10.8.tar.xz && tar xvf gexiv2-0.10.8.tar.xz && cd gexiv2-0.10.8 && ./configure --prefix=/zyx && make V=1 -j 2 install) || exit 1
fi


if [ ! -e /work/libcanberra-0.30 ]; then
(cd /work && rm -rf libcanberra* && wget http://0pointer.de/lennart/projects/libcanberra/libcanberra-0.30.tar.xz && tar xJvf libcanberra-0.30.tar.xz && cd libcanberra-0.30 && ./configure --prefix=/zyx --enable-gtk-doc=no --enable-gtk-doc-html=no --enable-gtk-doc-pdf=no && make -j 2 && make install && rm -rf libcanberra-0.30) || exit 1
fi


if [ ! -e /work/libmypaint-1.3.0 ]; then
  (cd /work && rm -rf libmypaint* && wget https://github.com/mypaint/libmypaint/releases/download/v1.3.0/libmypaint-1.3.0.tar.xz && tar xvf libmypaint-1.3.0.tar.xz && cd libmypaint-1.3.0 && ./configure --prefix=/zyx --disable-gegl && make -j 2 install) || exit 1
fi

if [ ! -e /work/mypaint-brushes ]; then
(cd /work && rm -rf mypaint-brushes && git clone -b v1.3.x https://github.com/Jehan/mypaint-brushes && cd mypaint-brushes && ./autogen.sh && ./configure --prefix=/zyx && make && make install && rm -rf mypaint-brushes) || exit 1
fi


if [ ! -e /work/babl ]; then
if [ x"$BABL_GIT_TAG" = "x" ]; then
	(cd /work && rm -rf babl && git clone -b master https://gitlab.gnome.org/GNOME/babl.git) || exit 1
else
	(cd /work && rm -rf babl && git clone -b "$BABL_GIT_TAG" https://gitlab.gnome.org/GNOME/babl.git) || exit 1
fi
(cd /work/babl && ./autogen.sh --prefix=/zyx && make -j 2 install) || exit 1
fi

if [ ! -e /work/gegl ]; then
if [ x"$GEGL_GIT_TAG" = "x" ]; then
	(cd /work && rm -rf gegl && git clone -b master https://gitlab.gnome.org/GNOME/gegl.git) || exit 1
else
	(cd /work && rm -rf gegl && git clone -b "$GEGL_GIT_TAG" https://gitlab.gnome.org/GNOME/gegl.git) || exit 1
fi
(cd /work/gegl && ./autogen.sh --prefix=/zyx --without-libavformat --enable-docs=no --enable-gtk-doc=no --enable-gtk-doc-html=no --enable-gtk-doc-pdf=no && make -j 2 install) || exit 1
fi

if [ ! -e /work/gimp ]; then
if [ x"$GIMP_GIT_TAG" = "x" ]; then
	(cd /work && rm -rf gimp && git clone -b gimp-2-10 https://gitlab.gnome.org/GNOME/gimp.git) || exit 1
else
	(cd /work && rm -rf gimp && git clone -b "$GIMP_GIT_TAG" https://gitlab.gnome.org/GNOME/gimp.git) || exit 1
fi
fi
(cd /work/gimp && patch -N -p0 < /sources/gimp-glib-splash.patch)
(cd /work/gimp && ./autogen.sh --prefix=/zyx --without-gnomevfs --with-gimpdir=GIMP-AppImage --enable-binreloc && make -j 2 install) || exit 1

fi

bash /sources/mkappimage
