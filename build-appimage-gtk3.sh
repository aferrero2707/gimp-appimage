#! /bin/bash

export PKG_CONFIG_PATH=/${AIPREFIX}/lib64/pkgconfig:/${AIPREFIX}/lib/pkgconfig:/${AIPREFIX}/share/pkgconfig:$PKG_CONFIG_PATH
export ACLOCAL_PATH=/${AIPREFIX}/share/aclocal:$ACLOCAL_PATH
export LD_LIBRARY_PATH=/${AIPREFIX}/lib64:/${AIPREFIX}/lib:$LD_LIBRARY_PATH

#(yum update -y && yum install -y epel-release && yum update -y && yum install -y libtool-ltdl-devel autoconf automake libtools which json-c-devel json-glib-devel gtk-doc gperf libuuid-devel libcroco-devel) || exit 1
#(yum-config-manager --add-repo http://www.nasm.us/nasm.repo && yum update -y && yum install -y suitesparse-devel libunwind-devel libwmf-devel openjpeg2-devel libmng-devel libXpm-devel iso-codes-devel mercurial numactl-devel nasm gnome-common libappstream-glib-devel poppler-glib-devel) || exit 1
(yum install -y suitesparse-devel libunwind-devel libwmf-devel openjpeg2-devel libmng-devel libXpm-devel iso-codes-devel mercurial numactl-devel gnome-common libappstream-glib-devel poppler-glib-devel) || exit 1

yum install -y https://centos7.iuscommunity.org/ius-release.rpm  && yum update -y
yum install -y python3 python3-libs python3-devel python3-pip || exit 1
#pip3.6 install --upgrade pip || exit 1
pip3.6 install meson ninja pycairo PyGObject || exit 1
#locale-gen en_US.UTF-8
localectl set-locale LANG=en_US.utf8
export LANG=en_US.UTF-8 LANGUAGE=en_US.en LC_ALL=en_US.UTF-8


if [ ! -e /work/poppler-done ]; then
#(cd /work && rm -rf freetype-2.9 && \
#wget https://download.savannah.gnu.org/releases/freetype/freetype-2.9.tar.gz && \
#tar xf freetype-2.9.tar.gz && cd freetype-2.9 && \
#./configure --prefix=/${AIPREFIX} && make -j 2 install) || exit 1
ldd /zyx/lib/libcairo.so
(cd /work && rm -rf poppler-0.74.0 && wget https://poppler.freedesktop.org/poppler-0.74.0.tar.xz && \
tar xf poppler-0.74.0.tar.xz && cd poppler-0.74.0 && mkdir -p build && cd build && \
Freetype_DIR=/${AIPREFIX} Fontconfig_DIR=/${AIPREFIX} cmake -DCMAKE_PREFIX_PATH=/${AIPREFIX} -DCMAKE_INSTALL_PREFIX=/${AIPREFIX} .. && \
make -j 3 install) || exit 1
touch /work/poppler-done
fi


if [ ! -e /work/libarchive-done ]; then
(cd /work && rm -rf libarchive* && wget https://github.com/libarchive/libarchive/releases/download/v3.4.0/libarchive-3.4.0.tar.gz && \
tar xf libarchive-3.4.0.tar.gz && cd libarchive* && ./configure --prefix=/${AIPREFIX} && make -j 2 install) || exit 1
touch /work/libarchive-done
fi


#if [ ! -e /work/build/pycairo-1.17.1 ]; then
#  (mkdir -p /work/build && cd /work/build && rm -rf pycairo* && wget https://github.com/pygobject/pycairo/releases/download/v1.17.1/pycairo-1.17.1.tar.gz && tar xvf pycairo-1.17.1.tar.gz && cd pycairo-1.17.1 && meson --prefix /zyx builddir &&  meson configure -Dpython=python3 --prefix /usr builddir && cd builddir && ninja && ninja install) || exit 1
#  exit
#fi


#if [ ! -e /work/pygobbject-done ]; then
#  (cd /work && rm -rf pygobject*  && wget https://ftp.gnome.org/pub/GNOME/sources/pygobject/3.34/pygobject-3.34.0.tar.xz && tar xvf pygobject-3.34.0.tar.xz && cd pygobject-3.34.0 && meson --prefix /usr build && cd build && ninja && ninja install) || exit 1
#touch /work/pygobbject-done
#fi


#if [ ! -e /work/heif-done ]; then
(cd /work && rm -rf libheif && git clone -b v1.8.0 https://github.com/strukturag/libheif.git && \
cd libheif && ./autogen.sh && ./configure --prefix=/${AIPREFIX}  && make -j 2 install && \
cd / && rm -rf /work/libheif) || exit 1
touch /work/heif-done
#fi



export GIMPPREFIX=/usr/local/gimp
export PKG_CONFIG_PATH=${GIMPPREFIX}/lib64/pkgconfig:${GIMPPREFIX}/lib/pkgconfig:${GIMPPREFIX}/share/pkgconfig:$PKG_CONFIG_PATH
export ACLOCAL_PATH=${GIMPPREFIX}/share/aclocal:$ACLOCAL_PATH
export LD_LIBRARY_PATH=${GIMPPREFIX}/lib64:${GIMPPREFIX}/lib:$LD_LIBRARY_PATH
export PATH=${GIMPPREFIX}/bin:$PATH

export LANG="en_US.UTF-8"
export XDG_DATA_DIRS=$XDG_DATA_DIRS:${GIMPPREFIX}/share:/usr/share


if [ ! -e /work/babl ]; then
	if [ x"$BABL_GIT_TAG" = "x" -o x"$GIMP_GIT_TAG" = "x" ]; then
		(cd /work && rm -rf babl && \
			git clone -b master https://gitlab.gnome.org/GNOME/babl.git) || exit 1
	else
		(cd /work && rm -rf babl && \
			git clone -b "$BABL_GIT_TAG" https://gitlab.gnome.org/GNOME/babl.git) || exit 1
	fi
	cd /work/babl || exit 1
	if [ -e ./autogen.sh ]; then
		(./autogen.sh --prefix=${GIMPPREFIX} && make -j 2 install) || exit 1
	else
		(meson --prefix ${GIMPPREFIX} build && cd build && ninja && ninja install) || exit 1
	fi
fi


if [ ! -e /work/gegl ]; then
	if [ x"$GEGL_GIT_TAG" = "x" -o x"$GIMP_GIT_TAG" = "x" ]; then
		(cd /work && rm -rf gegl && \
			git clone -b master https://gitlab.gnome.org/GNOME/gegl.git) || exit 1
	else
		(cd /work && rm -rf gegl && \
			git clone -b "$GEGL_GIT_TAG" https://gitlab.gnome.org/GNOME/gegl.git) || exit 1
	fi
	cd /work/gegl || exit 1
	if [ -e ./autogen.sh ]; then
		(./autogen.sh --prefix=${GIMPPREFIX} --without-libavformat --enable-docs=no --enable-gtk-doc=no --enable-gtk-doc-html=no --enable-gtk-doc-pdf=no && make -j 2 install) || exit 1
	else
		(meson build && meson configure -Dprefix=${GIMPPREFIX} -Dlibav=disabled -Ddocs=false build && cd build && ninja && ninja install) || exit 1
	fi
fi


if [ ! -e /work/gimp-done ]; then
	if [ x"$GIMP_GIT_TAG" = "x" ]; then
		(cd /work && rm -rf gimp && \
			git clone -b master https://gitlab.gnome.org/GNOME/gimp.git) || exit 1
	else
		(cd /work && rm -rf gimp && \
			git clone -b "$GIMP_GIT_TAG" https://gitlab.gnome.org/GNOME/gimp.git) || exit 1
	fi
	#(cd /work/gimp && patch -N -p0 < /sources/gimp-glib-splash.patch)
	cd /work/gimp || exit 1
	if [ -e ./autogen.sh ]; then
		(sed -i -e 's|m4_define(\[gtk_required_version\], \[2.24.32\])|m4_define(\[gtk_required_version\], \[2.24.31\])|g' configure.ac) || exit 1
		(./autogen.sh --prefix=${GIMPPREFIX} --without-gnomevfs --with-gimpdir=GIMP-AppImage --enable-binreloc --with-javascript=force --with-lua=force && make -j 2 install) || exit 1
	else
		(meson build && meson configure -Dprefix=${GIMPPREFIX} -Djavascript=never -Dlua=never -Drelocatable-bundle=enabled -Dgimpdir=GIMP-AppImage build && cd build && ninja && ninja install) || exit 1
	fi
	touch /work/gimp-done
fi
