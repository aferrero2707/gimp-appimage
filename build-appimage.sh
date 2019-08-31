#! /bin/bash

export PKG_CONFIG_PATH=/${AIPREFIX}/lib64/pkgconfig:/${AIPREFIX}/lib/pkgconfig:/${AIPREFIX}/share/pkgconfig:$PKG_CONFIG_PATH
export ACLOCAL_PATH=/${AIPREFIX}/share/aclocal:$ACLOCAL_PATH
export LD_LIBRARY_PATH=/${AIPREFIX}/lib64:/${AIPREFIX}/lib:$LD_LIBRARY_PATH

#(yum update -y && yum install -y epel-release && yum update -y && yum install -y libtool-ltdl-devel autoconf automake libtools which json-c-devel json-glib-devel gtk-doc gperf libuuid-devel libcroco-devel) || exit 1
(yum-config-manager --add-repo http://www.nasm.us/nasm.repo && yum update -y && yum install -y suitesparse-devel libunwind-devel libwmf-devel openjpeg2-devel libmng-devel libXpm-devel iso-codes-devel mercurial numactl-devel nasm gnome-common alsa-lib-devel libgudev1-devel libappstream-glib desktop-file-utils meson ninja) || exit 1


export GIMPPREFIX=/usr/local/gimp
export PKG_CONFIG_PATH=${GIMPPREFIX}/lib64/pkgconfig:${GIMPPREFIX}/lib/pkgconfig:${GIMPPREFIX}/share/pkgconfig:$PKG_CONFIG_PATH
export ACLOCAL_PATH=${GIMPPREFIX}/share/aclocal:$ACLOCAL_PATH
export LD_LIBRARY_PATH=${GIMPPREFIX}/lib64:${GIMPPREFIX}/lib:$LD_LIBRARY_PATH
export PATH=${GIMPPREFIX}/bin:$PATH

#export BABL_GIT_TAG=BABL_0_1_62
#export GEGL_GIT_TAG=GEGL_0_4_14


if [ ! -e /work/babl ]; then
	if [ x"$BABL_GIT_TAG" = "x" -o x"$GIMP_GIT_TAG" = "x" ]; then
		(cd /work && rm -rf babl && \
			git clone -b master --depth=1 https://gitlab.gnome.org/GNOME/babl.git) || exit 1
	else
		(cd /work && rm -rf babl && \
			git clone -b "$BABL_GIT_TAG" --depth=1 https://gitlab.gnome.org/GNOME/babl.git) || exit 1
	fi
	cd /work/babl || exit 1
	if [ -e ./autogen.sh ]; then
		(./autogen.sh --prefix=${GIMPPREFIX} && make -j 2 install) || exit 1)
	else
		(meson --prefix ${GIMPPREFIX} build && cd build && ninja && ninja install) || exit 1
	fi
fi


if [ ! -e /work/gegl ]; then
	if [ x"$GEGL_GIT_TAG" = "x" -o x"$GIMP_GIT_TAG" = "x" ]; then
		(cd /work && rm -rf gegl && \
			git clone -b master --depth=1 https://gitlab.gnome.org/GNOME/gegl.git) || exit 1
	else
		(cd /work && rm -rf gegl && \
			git clone -b "$GEGL_GIT_TAG" --depth=1 https://gitlab.gnome.org/GNOME/gegl.git) || exit 1
	fi
	cd /work/gegl || exit 1
	if [ -e ./autogen.sh ]; then
		(./autogen.sh --prefix=${GIMPPREFIX} --without-libavformat --enable-docs=no --enable-gtk-doc=no --enable-gtk-doc-html=no --enable-gtk-doc-pdf=no && make -j 2 install) || exit 1)
	else
		(meson build && meson configure -Dprefix=${GIMPPREFIX} -Dlibav=false -Ddocs=false build && cd build && ninja && ninja install) || exit 1
	fi
fi


if [ ! -e /work/gimp ]; then
	if [ x"$GIMP_GIT_TAG" = "x" ]; then
		(cd /work && rm -rf gimp && \
			git clone -b gimp-2-10 --depth=1 https://gitlab.gnome.org/GNOME/gimp.git) || exit 1
	else
		(cd /work && rm -rf gimp && \
			git clone -b "$GIMP_GIT_TAG" --depth=1 https://gitlab.gnome.org/GNOME/gimp.git) || exit 1
	fi
	#(cd /work/gimp && patch -N -p0 < /sources/gimp-glib-splash.patch)
	(cd /work/gimp && patch -N -p1 < /sources/gimp-mypaint-brush-dir.patch) || exit 1
	(cd /work/gimp && sed -i -e 's|m4_define(\[gtk_required_version\], \[2.24.32\])|m4_define(\[gtk_required_version\], \[2.24.31\])|g' configure.ac && \
	./autogen.sh --prefix=${GIMPPREFIX} --without-gnomevfs --with-gimpdir=GIMP-AppImage --enable-relocatable-bundle && make -j 2 install) || exit 1
fi
