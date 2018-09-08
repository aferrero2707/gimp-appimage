#! /bin/bash

export PKG_CONFIG_PATH=/zyx/lib64/pkgconfig:/zyx/lib/pkgconfig:/zyx/share/pkgconfig:$PKG_CONFIG_PATH
export ACLOCAL_PATH=/zyx/share/aclocal:$ACLOCAL_PATH
export LD_LIBRARY_PATH=/zyx/lib64:/zyx/lib:$LD_LIBRARY_PATH




yum install -y gnome-common
(cd /work && rm -rf gtkimageview && git clone https://github.com/aferrero2707/gtkimageview.git && \
cd gtkimageview && patch -N -p0 < /sources/gtkimageview-Werror.patch && \
./autogen.sh --prefix=/zyx && make -j 2 install) || exit 1
(cd /work && rm -rf nufraw* && \
wget https://launchpad.net/~dhor/+archive/ubuntu/myway/+sourcefiles/nufraw/0.42-1dhor~xenial/nufraw_0.42.orig.tar.xz && \
tar xvf nufraw_0.42.orig.tar.xz && cd nufraw-0.42 && ./autogen.sh && \
./configure --enable-contrast --prefix=/zyx && make -j 2 install) || exit 1


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


yum install -y qt5-qtbase-devel qt5-linguist
(cd /work && rm -rf gmic gmic-qt && \
git clone https://github.com/dtschump/gmic.git && git clone https://github.com/c-koi/gmic-qt.git && \
make -C gmic/src CImg.h gmic_stdlib.h && cd gmic-qt && mkdir -p build && cd build && \
cmake .. -DGMIC_QT_HOST=gimp -DCMAKE_BUILD_TYPE=Release && make) || exit 1

gimplibdir=$(pkg-config --variable=gimplibdir gimp-2.0)
echo "gimplibdir: $gimplibdir"
if [ -z "$gimplibdir" ]; then exit 1; fi

mkdir -p "$gimplibdir/plug-ins" || exit 1
cp -a /work/gmic-qt/build/gmic_gimp_qt "$gimplibdir/plug-ins" || exit 1



echo "Installing the GIMP scripts"
gimpdatadir=$(pkg-config --variable=gimpdatadir gimp-2.0)
(cd /work && rm -rf gimp-scripts && mkdir -p gimp-scripts && cd gimp-scripts && \
wget https://github.com/pixlsus/GIMP-Scripts/archive/master.zip && \
unzip master.zip && mkdir -p "$gimpdatadir/scripts" && \
cp GIMP-Scripts-master/*.scm "$gimpdatadir/scripts") || true
