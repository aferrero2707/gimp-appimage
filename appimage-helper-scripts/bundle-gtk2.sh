#! /bin/bash

echo ""
echo "########################################################################"
echo ""
echo "Copying GTK libraries and configuration files"
echo ""

# Manually copy librsvg, because it is not picked automatically by copy_deps
echo "========= copying LibRSVG ========="
mkdir -p ./usr/lib
RSVG_LIBDIR=$(pkg-config --variable=libdir librsvg-2.0)
if [ x"${RSVG_LIBDIR}" != "x" ]; then
	echo "cp -a ${RSVG_LIBDIR}/librsvg*.so* ./usr/lib"
	cp -a "${RSVG_LIBDIR}"/librsvg*.so* ./usr/lib
fi


echo ""
echo "========= compile Glib schemas ========="
# Compile Glib schemas
glib_prefix="$(pkg-config --variable=prefix glib-2.0)"
(mkdir -p usr/share/glib-2.0/schemas/ && \
cp -a ${glib_prefix}/share/glib-2.0/schemas/* usr/share/glib-2.0/schemas && \
cd usr/share/glib-2.0/schemas/ && \
glib-compile-schemas .) || exit 1

# Copy gconv ???
#cp -a /usr/lib64/gconv usr/lib



echo ""
echo "========= copy gdk-pixbuf modules and cache file ========="
# Copy gdk-pixbuf modules and cache file, and patch the cache file
# so that modules are picked from the AppImage bundle
gdk_pixbuf_moduledir="$(pkg-config --variable=gdk_pixbuf_moduledir gdk-pixbuf-2.0)"
gdk_pixbuf_cache_file="$(pkg-config --variable=gdk_pixbuf_cache_file gdk-pixbuf-2.0)"
gdk_pixbuf_libdir_bundle="lib/gdk-pixbuf-2.0"
gdk_pixbuf_cache_file_bundle="usr/${gdk_pixbuf_libdir_bundle}/loaders.cache"

mkdir -p "usr/${gdk_pixbuf_libdir_bundle}"
cp -a "$gdk_pixbuf_moduledir" "usr/${gdk_pixbuf_libdir_bundle}"
cp -a "$gdk_pixbuf_cache_file" "usr/${gdk_pixbuf_libdir_bundle}"
sed -i -e "s|${gdk_pixbuf_moduledir}/|LOADERSDIR/|g" "$gdk_pixbuf_cache_file_bundle"
#sed -i -e "s|${gdk_pixbuf_moduledir}/||g" "$gdk_pixbuf_cache_file_bundle"

printf '%s\n' "" "==================" "gdk-pixbuf cache:"
cat "$gdk_pixbuf_cache_file_bundle"
printf '%s\n' "==================" "gdk-pixbuf loaders:"
ls "usr/${gdk_pixbuf_libdir_bundle}/loaders"
printf '%s\n' "=================="


echo ""
echo "========= copy the theme engines ========="
# Copy the theme engines
mkdir -p usr/lib/gtk-2.0
GTK_LIBDIR=$(pkg-config --variable=libdir gtk+-2.0)
GTK_BINARY_VERSION=$(pkg-config --variable=gtk_binary_version gtk+-2.0)
cp -a "${GTK_LIBDIR}/gtk-2.0/${GTK_BINARY_VERSION}"/* usr/lib/gtk-2.0


echo ""
echo "========= fix PANGO cache file ========="
# Remove absolute paths from pango modules cache (if existing)
pqm="$(which pango-querymodules)"
if [[ ! -z $pqm ]]; then
  version="$(pango-querymodules --version | tail -n 1 | tr -d " " | cut -d':' -f 2)"
  cat "/${PREFIX}/lib/pango/${version}/modules.cache" | sed "s|/${PREFIX}/lib/pango/${version}/modules/||g" > "usr/lib/pango/${version}/modules.cache"
fi


