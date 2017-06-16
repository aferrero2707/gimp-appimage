#! /bin/bash

mkdir -p work
cd work

WD=$(pwd)
prefix=$WD/inst

export PATH=/zzz/bin:$prefix/bin:$PATH
export LD_LIBRARY_PATH=/zzz/lib:$prefix/lib:$LD_LIBRARY_PATH

export CHECKOUTROOT=$WD/sources
export BUILDROOT=$WD/build

jhbuild -f "$WD/../gimp.jhbuildrc" -m "$WD/../modulesets/gimp.modules" build --skip harfbuzz,liblzma,json-c $*
