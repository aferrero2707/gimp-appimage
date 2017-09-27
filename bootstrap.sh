#! /bin/bash

if [ ! -e /zzz ]; then
    username=$(whoami)
    groupname=$(id -gn $username)
    sudo mkdir -p /zzz
    sudo chown -R $username:$groupname /zzz
fi

mkdir -p work
cd work

WD=$(pwd)
prefix=$WD/inst

export PATH=/zzz/bin:$prefix/bin:$PATH
export LD_LIBRARY_PATH=/zzz/lib:$prefix/lib:$LD_LIBRARY_PATH

if [ ! -e "$prefix/bin" ]; then
    (rm -rf Python-2.7.13* && wget https://www.python.org/ftp/python/2.7.13/Python-2.7.13.tar.xz && tar xJvf Python-2.7.13.tar.xz && cd Python-2.7.13 && ./configure --prefix=/zzz --enable-shared --enable-unicode=ucs2 && make && make install)
    (rm -rf jhbuild && git clone https://github.com/GNOME/jhbuild.git && cd jhbuild && ./autogen.sh --prefix=$prefix && make && make install)
fi

# Some packages do not work with autotools versions later than 1.11
# Let's fool them with symbolic links to the available versions, 
# which are likely newer. This trick has no bad side-effects AFAIK
(cd "$prefix/bin" && rm -f automake-1.11 && ln -s $(which automake) automake-1.11 && rm -f aclocal-1.11 && ln -s $(which aclocal) aclocal-1.11)



export CHECKOUTROOT=$WD/sources
export BUILDROOT=$WD/build

jhbuild -f "$WD/../gimp.jhbuildrc" -m "$WD/../modulesets/gimp.modules" build gettext
#jhbuild -f "$WD/../gimp.jhbuildrc" -m "$WD/../modulesets/gimp.modules" build python2

jhbuild -f "$WD/../gimp.jhbuildrc" -m "$WD/../modulesets/gimp.modules" build gimp-bootstrap
