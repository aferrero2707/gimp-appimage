#! /bin/bash

PKG_CONFIG_PATH=/app/share/pkgconfig:$PKG_CONFIG_PATH

jhbuild -f "/sources/gimp.jhbuildrc" -m "/work/conf/modulesets/gimp.modules" build -t json-glib json-glib 
jhbuild -f "/sources/gimp.jhbuildrc" -m "/work/conf/modulesets/gimp.modules" build -t poppler-data poppler-data

jhbuild -f "/sources/gimp.jhbuildrc" -m "/work/conf/modulesets/gimp.modules" build -t babl babl
jhbuild -f "/sources/gimp.jhbuildrc" -m "/work/conf/modulesets/gimp.modules" build -t gegl gegl
jhbuild -f "/sources/gimp.jhbuildrc" -m "/work/conf/modulesets/gimp.modules" build -t libmypaint libmypaint
jhbuild -f "/sources/gimp.jhbuildrc" -m "/work/conf/modulesets/gimp.modules" build -t gimp gimp
jhbuild -f "/sources/gimp.jhbuildrc" -m "/work/conf/modulesets/gimp.modules" build -t phfgimp phfgimp
jhbuild -f "/sources/gimp.jhbuildrc" -m "/work/conf/modulesets/gimp.modules" build -t nufraw nufraw
jhbuild -f "/sources/gimp.jhbuildrc" -m "/work/conf/modulesets/gimp.modules" build -t resynthesizer resynthesizer
jhbuild -f "/sources/gimp.jhbuildrc" -m "/work/conf/modulesets/gimp.modules" build -t gimp-lqr-plugin gimp-lqr-plugin
