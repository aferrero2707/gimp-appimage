#! /bin/bash
(mkdir -p /work && cd /work) || exit 1
(rm -rf gcc-* && wget ftp://ftp.lip6.fr/pub/gcc/releases/gcc-6.4.0/gcc-6.4.0.tar.xz && \
tar xJf gcc-6.4.0.tar.xz && cd gcc-6.4.0 && \
./contrib/download_prerequisites && \
./configure --enable-languages=c,c++ --prefix=/work/inst --program-suffix="" --program-prefix="" --enable-shared --enable-linker-build-id --libexecdir=/work/inst/lib --without-included-gettext --enable-threads=posix --libdir=/work/inst/lib --enable-nls --with-sysroot=/ --enable-clocale=gnu --enable-libstdcxx-debug --enable-libstdcxx-time=yes --with-default-libstdcxx-abi=gcc4-compatible --enable-gnu-unique-object --disable-vtable-verify --enable-libmpx --enable-plugin --with-system-zlib --with-arch-directory=amd64 --with-target-system-zlib --enable-multiarch --disable-werror --with-arch-32=i686 --with-abi=m64 --with-multilib-list=m64 --enable-multilib --with-tune=generic --enable-checking=release --build=x86_64-linux-gnu --host=x86_64-linux-gnu --target=x86_64-linux-gnu && \
make -j 2 && make install) || exit 1

(cd /work/inst/bin && rm -f cc && ln -s gcc cc) || exit 1

(cp -L /etc/ld.so.conf /etc/ld.so.conf.bak && echo "/work/inst/lib64" > /etc/ld.so.conf && \
cat /etc/ld.so.conf.bak >> /etc/ld.so.conf && rm -f /etc/ld.so.conf.bak && rm -f /etc/ld.so.cache) || exit 1
ldconfig

rm -rf /work/gcc-*