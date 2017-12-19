FROM ubuntu:14.04

RUN adduser --debug --system --group --home /var/lib/colord colord --quiet 

# Install system packages
RUN apt-get update && apt-get install -y software-properties-common \
gcc g++ intltool libpng12-dev make nasm \
automake libfftw3-dev libjpeg-turbo8-dev \
libpng12-dev libwebp-dev libtiff4-dev libxml2-dev swig libmagick++-dev \
bc libcfitsio3-dev libgsl0-dev libmatio-dev liborc-0.4-dev \
libgif-dev libpugixml-dev wget git itstool \
bison flex ragel unzip libdbus-1-dev libxtst-dev \
cargo mesa-common-dev libgl1-mesa-dev libegl1-mesa-dev valac \
libxml2-utils xsltproc docbook-xsl libffi-dev \
 libvorbis-dev python-six gtk-doc-tools libicu-dev 
 
ADD build_gcc.sh /work/build_gcc.sh
RUN bash /work/build_gcc.sh && mkdir -p /work/conf/modulesets
COPY *.patch /work/conf/
COPY gimp.jhbuildrc /work/conf/
#COPY modulesets-bootstrap/* /work/conf/modulesets-bootstrap/
COPY modulesets/* /work/conf/modulesets/


# Set environment variables
ENV PATH=/app/bin:/work/inst/bin:$PATH LD_LIBRARY_PATH=/app/lib:/work/inst/lib64:/work/inst/lib:$LD_LIBRARY_PATH   PKG_CONFIG_PATH=/app/share/pkgconfig:/app/lib/pkgconfig:/work/inst/lib/pkgconfig:$PKG_CONFIG_PATH CHECKOUTROOT=/work/sources BUILDROOT=/work/build ACLOCAL_PATH=/app/share/aclocal:$ACLOCAL_PATH

# Get auxiliary configuration files and compile base dependencies
RUN mkdir -p /work && cd /work && \
rm -rf Python-2.7.13* && wget https://www.python.org/ftp/python/2.7.13/Python-2.7.13.tar.xz && tar xJvf Python-2.7.13.tar.xz && cd Python-2.7.13 && ./configure --prefix=/app --enable-shared --enable-unicode=ucs2 && make && make install && \
cd /work && rm -rf jhbuild && git clone https://github.com/GNOME/jhbuild.git && cd jhbuild && patch -p1 -i /work/conf/jhbuild-run-as-root.patch && ./autogen.sh --prefix=/work/inst && make -j 2 install && \
cd /work && rm -rf cmake* && wget https://cmake.org/files/v3.8/cmake-3.8.2.tar.gz && tar xzvf cmake-3.8.2.tar.gz && cd cmake-3.8.2 && ./bootstrap --prefix=/work/inst --parallel=2 && make -j 2 && make install && \
cd /work && wget https://github.com/ninja-build/ninja/releases/download/v1.8.2/ninja-linux.zip && unzip ninja-linux.zip && cp -a ninja /work/inst/bin && \
jhbuild -f "/work/conf/gimp.jhbuildrc" -m "/work/conf/modulesets/appimage.modules" build gettext && \
jhbuild -f "/work/conf/gimp.jhbuildrc" -m "/work/conf/modulesets/appimage.modules" build gimp-bootstrap && \
jhbuild -f "/work/conf/gimp.jhbuildrc" -m "/work/conf/modulesets/appimage.modules" build liblzma intltool glib glib-networking  gexiv2 openexr lcms json-glib && \
jhbuild -f "/work/conf/gimp.jhbuildrc" -m "/work/conf/modulesets/appimage.modules" build cairo && \
jhbuild -f "/work/conf/gimp.jhbuildrc" -m "/work/conf/modulesets/appimage.modules" build gdk-pixbuf && \
jhbuild -f "/work/conf/gimp.jhbuildrc" -m "/work/conf/modulesets/appimage.modules" build at-spi2-atk && \
jhbuild -f "/work/conf/gimp.jhbuildrc" -m "/work/conf/modulesets/appimage.modules" build gtk+ && \
jhbuild -f "/work/conf/gimp.jhbuildrc" -m "/work/conf/modulesets/appimage.modules" build librsvg && \
jhbuild -f "/work/conf/gimp.jhbuildrc" -m "/work/conf/modulesets/appimage.modules" build poppler poppler-data && \
jhbuild -f "/work/conf/gimp.jhbuildrc" -m "/work/conf/modulesets/appimage.modules" build dbus-glib && \
jhbuild -f "/work/conf/gimp.jhbuildrc" -m "/work/conf/modulesets/appimage.modules" build pygtk
#RUN jhbuild -f "/work/conf/gimp.jhbuildrc" -m "/work/conf/modulesets/appimage.modules" build libmypaint 

#cleanup
RUN rm -rf /gcc-* && cd /work && rm -rf checkout sources build gcc-* Python-* libepoxy* cmake* lcms2* libcanberra*
