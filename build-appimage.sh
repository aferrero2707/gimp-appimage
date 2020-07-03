#! /bin/bash

export PKG_CONFIG_PATH=/${AIPREFIX}/lib64/pkgconfig:/${AIPREFIX}/lib/pkgconfig:/${AIPREFIX}/share/pkgconfig:$PKG_CONFIG_PATH
export ACLOCAL_PATH=/${AIPREFIX}/share/aclocal:$ACLOCAL_PATH
export LD_LIBRARY_PATH=/${AIPREFIX}/lib64:/${AIPREFIX}/lib:$LD_LIBRARY_PATH

#(yum update -y && yum install -y epel-release && yum update -y && yum install -y libtool-ltdl-devel autoconf automake libtools which json-c-devel json-glib-devel gtk-doc gperf libuuid-devel libcroco-devel) || exit 1
#(yum-config-manager --add-repo http://www.nasm.us/nasm.repo && yum update -y && yum install -y suitesparse-devel libunwind-devel libwmf-devel openjpeg2-devel libmng-devel libXpm-devel iso-codes-devel mercurial numactl-devel nasm gnome-common alsa-lib-devel libgudev1-devel libappstream-glib desktop-file-utils) || exit 1
(yum update -y && yum install -y suitesparse-devel libunwind-devel libwmf-devel openjpeg2-devel libmng-devel libXpm-devel iso-codes-devel mercurial numactl-devel gnome-common alsa-lib-devel libgudev1-devel libappstream-glib desktop-file-utils) || exit 1

yum install -y https://centos7.iuscommunity.org/ius-release.rpm  && yum update -y
yum install -y python3 python3-libs python3-devel python3-pip || exit 1
#pip3.6 install --upgrade pip || exit 1
pip3.6 install meson ninja || exit 1


export GIMPPREFIX=/usr/local/gimp
export PKG_CONFIG_PATH=${GIMPPREFIX}/lib64/pkgconfig:${GIMPPREFIX}/lib/pkgconfig:${GIMPPREFIX}/share/pkgconfig:$PKG_CONFIG_PATH
export ACLOCAL_PATH=${GIMPPREFIX}/share/aclocal:$ACLOCAL_PATH
export LD_LIBRARY_PATH=${GIMPPREFIX}/lib64:${GIMPPREFIX}/lib:$LD_LIBRARY_PATH
export PATH=${GIMPPREFIX}/bin:$PATH

export LANG="en_US.UTF-8"
export XDG_DATA_DIRS=$XDG_DATA_DIRS:${GIMPPREFIX}/share:/usr/share

#export BABL_GIT_TAG=BABL_0_1_62
#export GEGL_GIT_TAG=GEGL_0_4_14

echo "BABL_GIT_TAG: ${BABL_GIT_TAG}"
echo "GEGL_GIT_TAG: ${GEGL_GIT_TAG}"
echo "GIMP_GIT_TAG: ${GIMP_GIT_TAG}"

if [ ! -e /work/babl.done ]; then
	if [ x"$BABL_GIT_TAG" = "x" -o x"$GIMP_GIT_TAG" = "x" ]; then
		echo "Cloning BABL git master"
		(cd /work && rm -rf babl && \
			git clone -b master --depth=1 https://gitlab.gnome.org/GNOME/babl.git) || exit 1
	else
		echo "Cloning BABL $BABL_GIT_TAG"
		(cd /work && rm -rf babl && \
			git clone -b "$BABL_GIT_TAG" --depth=1 https://gitlab.gnome.org/GNOME/babl.git) || exit 1
	fi
	cd /work/babl || exit 1
	if [ -e ./autogen.sh ]; then
		(./autogen.sh --prefix=${GIMPPREFIX} && make -j 2 install) || exit 1
	else
		(meson --prefix ${GIMPPREFIX} build && cd build && ninja && ninja install) || exit 1
	fi
	touch /work/babl.done
fi


if [ ! -e /work/gegl.done ]; then
	if [ x"$GEGL_GIT_TAG" = "x" -o x"$GIMP_GIT_TAG" = "x" ]; then
		echo "Cloning GEGL git master"
		(cd /work && rm -rf gegl && \
			git clone -b master --depth=1 https://gitlab.gnome.org/GNOME/gegl.git) || exit 1
	else
		echo "Cloning GEGL $GEGL_GIT_TAG"
		(cd /work && rm -rf gegl && \
			git clone -b "$GEGL_GIT_TAG" --depth=1 https://gitlab.gnome.org/GNOME/gegl.git) || exit 1
	fi
	cd /work/gegl || exit 1
	if [ -e ./autogen.sh ]; then
		(./autogen.sh --prefix=${GIMPPREFIX} --without-libavformat --enable-docs=no --enable-gtk-doc=no --enable-gtk-doc-html=no --enable-gtk-doc-pdf=no && make -j 2 install) || exit 1
	else
		(meson build && meson configure -Dprefix=${GIMPPREFIX} -Dlibav=disabled -Ddocs=false build && cd build && ninja && ninja install) || exit 1
	fi
	touch /work/gegl.done
fi


if [ ! -e /work/build/pycairo-1.17.1 ]; then
  (mkdir -p /work/build && cd /work/build && rm -rf pycairo* && wget https://github.com/pygobject/pycairo/releases/download/v1.17.1/pycairo-1.17.1.tar.gz && tar xvf pycairo-1.17.1.tar.gz && cd pycairo-1.17.1 && meson --prefix /zyx builddir &&  meson configure -Dpython=python2 --prefix /usr builddir && cd builddir && ninja && ninja install) || exit 1
fi

if [ ! -e /work/build/pygtk-2.24.0 ]; then
  (mkdir -p /work/build && cd /work/build && rm -rf pygtk* && wget https://ftp.acc.umu.se/pub/GNOME/sources/pygtk/2.24/pygtk-2.24.0.tar.bz2 && tar xvf pygtk-2.24.0.tar.bz2 && cd pygtk-2.24.0 && ./configure --prefix=/usr && make install) || exit 1
fi

echo "PKG_CONFIG_PATH: ${PKG_CONFIG_PATH}"
if [ ! -e /work/gimp.done ]; then
	if [ x"$GIMP_GIT_TAG" = "x" ]; then
		echo "Cloning GIMP 2-10"
		(cd /work && rm -rf gimp && \
			git clone -b gimp-2-10 --depth=1 https://gitlab.gnome.org/GNOME/gimp.git) || exit 1
	else
		echo "Cloning GIMP $GIMP_GIT_TAG"
		(cd /work && rm -rf gimp && \
			git clone -b "$GIMP_GIT_TAG" --depth=1 https://gitlab.gnome.org/GNOME/gimp.git) || exit 1
	fi
	#(cd /work/gimp && patch -N -p0 < /sources/gimp-glib-splash.patch)
	(cd /work/gimp && patch -N -p1 < /sources/gimp-mypaint-brush-dir.patch) || exit 1
	(cd /work/gimp && sed -i -e 's|m4_define(\[gtk_required_version\], \[2.24.32\])|m4_define(\[gtk_required_version\], \[2.24.31\])|g' configure.ac && \
	./autogen.sh --prefix=${GIMPPREFIX} --without-gnomevfs --with-gimpdir=GIMP-AppImage --enable-relocatable-bundle && make -j 2 install) || exit 1
	touch /work/gimp.done
fi
