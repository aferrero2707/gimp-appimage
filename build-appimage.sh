#! /bin/bash

export PKG_CONFIG_PATH=/app/share/pkgconfig:$PKG_CONFIG_PATH
export ACLOCAL_PATH=/app/share/aclocal:$ACLOCAL_PATH

jhbuild -f "/sources/gimp.jhbuildrc" -m "/work/conf/modulesets/gimp.modules" buildone --exit-on-error json-glib && \
jhbuild -f "/sources/gimp.jhbuildrc" -m "/work/conf/modulesets/gimp.modules" buildone --exit-on-error poppler-data && \
jhbuild -f "/sources/gimp.jhbuildrc" -m "/work/conf/modulesets/gimp.modules" buildone ---exit-on-error babl && \
jhbuild -f "/sources/gimp.jhbuildrc" -m "/work/conf/modulesets/gimp.modules" buildone --exit-on-error gegl && \
jhbuild -f "/sources/gimp.jhbuildrc" -m "/work/conf/modulesets/gimp.modules" buildone --exit-on-error libmypaint && \
jhbuild -f "/sources/gimp.jhbuildrc" -m "/work/conf/modulesets/gimp.modules" buildone --exit-on-error gimp && \
jhbuild -f "/sources/gimp.jhbuildrc" -m "/work/conf/modulesets/gimp.modules" buildone --exit-on-error phfgimp && \
jhbuild -f "/sources/gimp.jhbuildrc" -m "/work/conf/modulesets/gimp.modules" buildone --exit-on-error nufraw && \
jhbuild -f "/sources/gimp.jhbuildrc" -m "/work/conf/modulesets/gimp.modules" buildone --exit-on-error resynthesizer && \
jhbuild -f "/sources/gimp.jhbuildrc" -m "/work/conf/modulesets/gimp.modules" buildone --exit-on-error gimp-lqr-plugin
