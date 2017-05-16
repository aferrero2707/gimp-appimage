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

if [ ! -e "$prefix/bin" ]; then
    (rm -rf jhbuild && git clone git://git.gnome.org/jhbuild && cd jhbuild && ./autogen.sh --prefix=$prefix && make && make install)
fi

export PATH=$prefix/bin:$PATH
export LD_LIBRARY_PATH=$prefix/lib:$LD_LIBRARY_PATH
export CHECKOUTROOT=$WD/sources


jhbuild -f "$WD/../gimp.jhbuildrc" -m "$WD/../modulesets/gimp.modules" build --distclean gimp-bootstrap
jhbuild -f "$WD/../gimp.jhbuildrc" -m "$WD/../modulesets/gimp.modules" build --distclean --skip harfbuzz,liblzma,json-c $*
