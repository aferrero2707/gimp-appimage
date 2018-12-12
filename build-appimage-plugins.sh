#! /bin/bash

export PKG_CONFIG_PATH=/zyx/lib64/pkgconfig:/zyx/lib/pkgconfig:/zyx/share/pkgconfig:$PKG_CONFIG_PATH
export ACLOCAL_PATH=/zyx/share/aclocal:$ACLOCAL_PATH
export LD_LIBRARY_PATH=/zyx/lib64:/zyx/lib:$LD_LIBRARY_PATH

export GIMPPREFIX=/usr/local/gimp
export PKG_CONFIG_PATH=${GIMPPREFIX}/lib64/pkgconfig:${GIMPPREFIX}/lib/pkgconfig:${GIMPPREFIX}/share/pkgconfig:$PKG_CONFIG_PATH
export ACLOCAL_PATH=${GIMPPREFIX}/share/aclocal:$ACLOCAL_PATH
export LD_LIBRARY_PATH=${GIMPPREFIX}/lib64:${GIMPPREFIX}/lib:$LD_LIBRARY_PATH
export PATH=${GIMPPREFIX}/bin:$PATH


#(cd /work && rm -rf gutenprint* && \
# wget https://sourceforge.net/projects/gimp-print/files/gutenprint-5.3/5.3.1/gutenprint-5.3.1.tar.xz && \
# tar xf gutenprint-5.3.1.tar.xz && cd gutenprint-5.3.1 && ./configure CFLAGS='-g -O2' CXXFLAGS='-g -O2' --prefix=/zyx && make install) || exit 1
# exit


yum install -y qt5-qtbase-devel qt5-linguist libcurl-devel || exit 1
(cd /work && rm -rf gmic gmic-qt && \
git clone https://github.com/c-koi/gmic-qt.git && cd gmic-qt && \
git clone https://github.com/dtschump/gmic.git gmic-clone && \
make -C gmic-clone/src CImg.h gmic_stdlib.h && \
qmake-qt5 QMAKE_CFLAGS+="${CFLAGS} -O2" QMAKE_CXXFLAGS+="${CXXFLAGS} -O2" CONFIG+=Release HOST=gimp GMIC_PATH=gmic-clone/src && \
make -j 3 && make install) || exit 1

#cmake .. -DGMIC_QT_HOST=gimp -DCMAKE_BUILD_TYPE=Release && make) || exit 1

gimplibdir=$(pkg-config --variable=gimplibdir gimp-2.0)
echo "gimplibdir: $gimplibdir"
if [ -z "$gimplibdir" ]; then exit 1; fi

mkdir -p "$gimplibdir/plug-ins" || exit 1
cp -a /work/gmic-qt/gmic_gimp_qt "$gimplibdir/plug-ins" || exit 1


yum install -y gnome-common
(cd /work && rm -rf gtkimageview && git clone https://github.com/aferrero2707/gtkimageview.git && \
cd gtkimageview && patch -N -p0 < /sources/gtkimageview-Werror.patch && \
./autogen.sh --prefix=/usr/local && make -j 2 install) || exit 1
(cd /work && rm -rf nufraw* && \
wget https://launchpad.net/~dhor/+archive/ubuntu/myway/+sourcefiles/nufraw/0.42-1dhor~xenial/nufraw_0.42.orig.tar.xz && \
tar xvf nufraw_0.42.orig.tar.xz && cd nufraw-0.42 && ./autogen.sh && \
./configure --enable-contrast --prefix=/usr/local && make -j 2 install) || exit 1


(cd /work && rm -rf liblqr && git clone https://github.com/carlobaldassi/liblqr.git && \
cd liblqr && ./configure --prefix=/zyx && make -j 2 install) || exit 1
(cd /work && rm -rf gimp-lqr-plugin && git clone https://github.com/carlobaldassi/gimp-lqr-plugin.git && \
cd gimp-lqr-plugin && ./configure --prefix=/zyx && make -j 2 install) || exit 1


(cd /work && rm -rf PhFGimp && git clone https://github.com/aferrero2707/PhFGimp.git && \
mkdir PhFGimp/build && cd PhFGimp/build && \
cmake -DBABL_FLIPS_DISABLED=OFF -DCMAKE_BUILD_TYPE=Release .. && \
make -j 2 install) || exit 1


(cd /work && rm -rf resynthesizer && git clone https://github.com/bootchk/resynthesizer.git && \
cd resynthesizer && ./autogen.sh --prefix=/zyx && make -j 2 install) || exit 1



echo "Installing the GIMP scripts"
gimpdatadir=$(pkg-config --variable=gimpdatadir gimp-2.0)
(cd /work && rm -rf gimp-scripts && mkdir -p gimp-scripts && cd gimp-scripts && \
wget https://github.com/pixlsus/GIMP-Scripts/archive/master.zip && \
unzip master.zip && mkdir -p "$gimpdatadir/scripts" && \
cp GIMP-Scripts-master/*.scm "$gimpdatadir/scripts") || true
