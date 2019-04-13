#! /bin/bash

export PKG_CONFIG_PATH=/${AIPREFIX}/lib64/pkgconfig:/${AIPREFIX}/lib/pkgconfig:/${AIPREFIX}/share/pkgconfig:$PKG_CONFIG_PATH
export ACLOCAL_PATH=/${AIPREFIX}/share/aclocal:$ACLOCAL_PATH
export LD_LIBRARY_PATH=/${AIPREFIX}/lib64:/${AIPREFIX}/lib:$LD_LIBRARY_PATH

#(yum update -y && yum install -y epel-release && yum update -y && yum install -y libtool-ltdl-devel autoconf automake libtools which json-c-devel json-glib-devel gtk-doc gperf libuuid-devel libcroco-devel) || exit 1
(yum-config-manager --add-repo http://www.nasm.us/nasm.repo && yum update -y && yum install -y suitesparse-devel libunwind-devel libwmf-devel openjpeg2-devel libmng-devel libXpm-devel iso-codes-devel mercurial numactl-devel nasm gnome-common) || exit 1

if [ "x" = "y" ]; then

if [ ! -e /work/x265-done ]; then
(cd /work && rm -rf x265 && hg clone http://hg.videolan.org/x265 && \
cd x265 && mkdir -p build && cd build && \
cmake -DCMAKE_INSTALL_PREFIX=/${AIPREFIX} ../source && make -j 2 install) || exit 1

(cd /work && rm -rf libde265 && \
git clone -b frame-parallel https://github.com/strukturag/libde265.git && \
cd libde265 && mkdir build && ./autogen.sh && ./configure --prefix=/${AIPREFIX} --disable-dec265 --disable-sherlock265 && make -j 2 install)
touch /work/x265-done
fi

if [ ! -e /work/heif-done ]; then
(cd /work && rm -rf libheif && git clone -b v1.3.2 https://github.com/strukturag/libheif.git && \
cd libheif && ./autogen.sh && ./configure --prefix=/${AIPREFIX}  && make -j 2 install) || exit 1
touch /work/heif-done
fi

if [ ! -e /work/webp-done ]; then
# WebP - Windows Image Components not supported
echo "967b8f087cb392e6cc94d5e116a120c0  libwebp-1.0.0.tar.gz" > /work/libwebp-1.0.0.hash
(cd /work && rm -rf libwebp-1.0.0 && \
wget http://downloads.webmproject.org/releases/webp/libwebp-1.0.0.tar.gz &&\
md5sum --check libwebp-1.0.0.hash && tar xvf libwebp-1.0.0.tar.gz && \
cd libwebp-1.0.0 && ./configure --prefix=/${AIPREFIX} --enable-everything && make -j 2 install) || exit 1
touch /work/webp-done
fi

fi


export GIMPPREFIX=/usr/local/gimp
export PKG_CONFIG_PATH=${GIMPPREFIX}/lib64/pkgconfig:${GIMPPREFIX}/lib/pkgconfig:${GIMPPREFIX}/share/pkgconfig:$PKG_CONFIG_PATH
export ACLOCAL_PATH=${GIMPPREFIX}/share/aclocal:$ACLOCAL_PATH
export LD_LIBRARY_PATH=${GIMPPREFIX}/lib64:${GIMPPREFIX}/lib:$LD_LIBRARY_PATH
export PATH=${GIMPPREFIX}/bin:$PATH

export BABL_GIT_TAG=BABL_0_1_62
export GEGL_GIT_TAG=GEGL_0_4_14


if [ ! -e /work/babl ]; then
	if [ x"$BABL_GIT_TAG" = "x" ]; then
		(cd /work && rm -rf babl && \
			git clone -b master https://gitlab.gnome.org/GNOME/babl.git) || exit 1
	else
		(cd /work && rm -rf babl && \
			git clone -b "$BABL_GIT_TAG" https://gitlab.gnome.org/GNOME/babl.git) || exit 1
	fi
	(cd /work/babl && ./autogen.sh --prefix=${GIMPPREFIX} && make -j 2 install) || exit 1
fi


if [ ! -e /work/gegl ]; then
	if [ x"$GEGL_GIT_TAG" = "x" ]; then
		(cd /work && rm -rf gegl && \
			git clone -b master https://gitlab.gnome.org/GNOME/gegl.git) || exit 1
	else
		(cd /work && rm -rf gegl && \
			git clone -b "$GEGL_GIT_TAG" https://gitlab.gnome.org/GNOME/gegl.git) || exit 1
	fi
	(cd /work/gegl && ./autogen.sh --prefix=${GIMPPREFIX} --without-libavformat --enable-docs=no --enable-gtk-doc=no --enable-gtk-doc-html=no --enable-gtk-doc-pdf=no && make -j 2 install) || exit 1
fi


if [ ! -e /work/gimp ]; then
	if [ x"$GIMP_GIT_TAG" = "x" ]; then
		(cd /work && rm -rf gimp && \
			git clone -b gimp-2-10 https://gitlab.gnome.org/GNOME/gimp.git) || exit 1
	else
		(cd /work && rm -rf gimp && \
			git clone -b "$GIMP_GIT_TAG" https://gitlab.gnome.org/GNOME/gimp.git) || exit 1
	fi
	#(cd /work/gimp && patch -N -p0 < /sources/gimp-glib-splash.patch)
	(cd /work/gimp && sed -i -e 's|m4_define(\[gtk_required_version\], \[2.24.32\])|m4_define(\[gtk_required_version\], \[2.24.31\])|g' configure.ac && \
	./autogen.sh --prefix=${GIMPPREFIX} --without-gnomevfs --with-gimpdir=GIMP-AppImage --enable-binreloc && make -j 2 install) || exit 1
fi
