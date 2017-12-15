#! /bin/bash

PKG_CONFIG_PATH=/app/share/pkgconfig:$PKG_CONFIG_PATH

jhbuild -f "/work/conf/gimp.jhbuildrc" -m "/work/conf/modulesets/gimp.modules" build json-glib poppler-data

jhbuild -f "/work/conf/gimp.jhbuildrc" -m "/work/conf/modulesets/gimp.modules" build -t babl babl
jhbuild -f "/work/conf/gimp.jhbuildrc" -m "/work/conf/modulesets/gimp.modules" build -t gegl gegl
jhbuild -f "/work/conf/gimp.jhbuildrc" -m "/work/conf/modulesets/gimp.modules" build -t libmypaint libmypaint
jhbuild -f "/work/conf/gimp.jhbuildrc" -m "/work/conf/modulesets/gimp.modules" build -t gimp gimp
jhbuild -f "/work/conf/gimp.jhbuildrc" -m "/work/conf/modulesets/gimp.modules" build -t phfgimp phfgimp
jhbuild -f "/work/conf/gimp.jhbuildrc" -m "/work/conf/modulesets/gimp.modules" build -t nufraw nufraw
jhbuild -f "/work/conf/gimp.jhbuildrc" -m "/work/conf/modulesets/gimp.modules" build -t resynthesizer resynthesizer
jhbuild -f "/work/conf/gimp.jhbuildrc" -m "/work/conf/modulesets/gimp.modules" build -t gimp-lqr-plugin gimp-lqr-plugin
