save_environment() {
	TMPFILE="$(mktemp)"
	env | tr '\n' '\0' > "$TMPFILE"
	export AIPENV="$TMPFILE"
}


make_temp_libdir() {
	AILIBDIR="$(mktemp -d)"
	export AILIBDIR
    export LD_LIBRARY_PATH=$AILIBDIR:$LD_LIBRARY_PATH
}


link_libraries() {
	ln -s "$APPDIR/usr/lib"/*.so* "$AILIBDIR"
}


fix_libxcb_dri3() {
	libxcbdri3="$(/sbin/ldconfig -p | grep 'libxcb-dri3.so.0 (libc6,x86-64'| awk 'NR==1{print $NF}')"
	temp="$(strings $libxcbdri3 | grep xcb_dri3_get_supported_modifiers)"
	if [ -n "$temp" ]; then
		echo "deleting $AILIBDIR/libxcb-dri3.so*"
		rm -f "$AILIBDIR"/libxcb-dri3.so*
	fi
}


fix_stdlibcxx() {
# libstdc++ version detection
stdcxxlib="$(/sbin/ldconfig -p | grep 'libstdc++.so.6 (libc6,x86-64)'| awk 'NR==1{print $NF}')"
echo "System stdc++ library: \"$stdcxxlib\""
stdcxxver1=$(strings "$stdcxxlib" | grep '^GLIBCXX_[0-9].[0-9]*' | cut -d"_" -f 2 | sort -V | tail -n 1)
echo "System stdc++ library version: \"$stdcxxver1\""
stdcxxver2=$(strings "$APPDIR/usr/optional/libstdc++/libstdc++.so.6" | grep '^GLIBCXX_[0-9].[0-9]*' | cut -d"_" -f 2 | sort -V | tail -n 1)
echo "Bundled stdc++ library version: \"$stdcxxver2\""
stdcxxnewest=$(echo "$stdcxxver1 $stdcxxver2" | tr " " "\n" | sort -V | tail -n 1)
echo "Newest stdc++ library version: \"$stdcxxnewest\""
if [[ x"$stdcxxnewest" = x"$stdcxxver1" ]]; then
   	echo "Using system stdc++ library"
else
   	echo "Using bundled stdc++ library"
	ln -s "$APPDIR/usr/optional/libstdc++"/*.so* "$AILIBDIR"
fi

atomiclib="$(/sbin/ldconfig -p | grep 'libatomic.so.1 (libc6,x86-64)'| awk 'NR==1{print $NF}')"
echo "atomiclib: $atomiclib"
if [[ x"$atomiclib" = "x" ]]; then
	echo "Using bundled atomic library"
	ln -s "$APPDIR/usr/optional/libstdc++"/libatomic.so* "$AILIBDIR"
fi
}


fix_fontconfig() {
# fonconfig version detection
fclib="$(/sbin/ldconfig -p | grep 'libfontconfig' | grep '(libc6,x86-64)'| awk 'NR==1{print $NF}')"
if [ -n "$fclib" ]; then
        fclib=$(readlink -f "$fclib")
        fcv=$(basename "$fclib" | tail -c +18)
fi
fclib2="$(ls $APPDIR/usr/optional/fontconfig/libfontconfig.so.*.*.* | head -n 1)"
if [ -n "$fclib2" ]; then
        fclib2=$(readlink -f "$fclib2")
        fcv2=$(basename "$fclib2" | tail -c +18)
fi
echo "fcv: \"$fcv\"  fcv2: \"$fcv2\""
if [ x"$fclib" = "x" ]; then
   echo "Ssystem fontconfig missing, using bundled fontconfig library"
   ln -s "$APPDIR/usr/optional/fontconfig"/*.so* "$AILIBDIR"
   export FONTCONFIG_PATH="$APPDIR/usr/etc/fonts/fonts.conf"
fi
if [ x"$fclib" != "x" -a x"$fclib2" != "x" ]; then
   echo "echo \"$fcv $fcv2\" | tr \" \" \"\n\" | sort -V | tail -n 1"
   fcvnewest=$(echo "$fcv $fcv2" | tr " " "\n" | sort -V | tail -n 1)

   echo "Newest fontconfig library version: \"$fcvnewest\""
   if [[ x"$fcvnewest" = x"$fcv" ]]; then
      echo "Using system fontconfig library"
      rm -f "$AILIBDIR"/libfontconfig*.so*
   else
      echo "Using bundled fontconfig library"
      ln -s "$APPDIR/usr/optional/fontconfig"/*.so* "$AILIBDIR"
      export FONTCONFIG_PATH="$APPDIR/usr/etc/fonts/fonts.conf"
   fi
fi
}


fix_library() {
	lib="$1"
	echo "Checking versions of library \"$lib\""
	syslib="$(/sbin/ldconfig -p | grep "$lib" | grep '(libc6,x86-64)'| awk 'NR==1{print $NF}')"
	if [ -n "$syslib" ]; then
	  syslib2="$(ls -1 "${syslib}"* | tail -n 1)"
	  syslib3="$(basename "$syslib2")"
	  echo "  system library: \"$syslib2\" ($syslib3)"
	  lv="$(echo "$syslib3" | sed 's/so\./\n/' | tail -n 1)"
	else
	  lv=""
	fi
	echo "  system library version: $lv"
	
	ailib="$(realpath "$(ls "$AILIBDIR/$lib.so"* | tail -n 1)")"
	echo "  ailib: \"$ailib\""
	if [ -n "$ailib" ]; then
	  ailib3="$(basename "$ailib")"
	  echo "  bundled library: \"$ailib\" ($ailib3)"
	  lv2="$(echo "$ailib3" | sed 's/so\./\n/' | tail -n 1)"
	else
	  lv2=""
	fi
	echo "  bundled library version: $lv2"
	
	lvn=$(echo "$lv $lv2" | tr " " "\n" | sort -V | tail -n 1)
    echo "  newest library version: \"$lvn\""
	if [ "$lvn" = "$lv" ]; then
	  echo "Removing bundled \"$lib\""
	  rm -v -f "${AILIBDIR}/$lib.so"*
	fi
}




# Execute user-supplied startup hook scripts
run_hooks()
{
  for h in "$APPDIR/startup_scripts"/*.sh; do
    source "$h"
  done
}


init_gdk_pixbuf()
{
  mkdir -p "$AILIBDIR/gdk-pixbuf-2.0"
  cp "${APPDIR}/usr/lib/gdk-pixbuf-2.0/loaders.cache" "$AILIBDIR/gdk-pixbuf-2.0"
  sed -i -e "s|LOADERSDIR|${APPDIR}/usr/lib/gdk-pixbuf-2.0/loaders|g" "$AILIBDIR/gdk-pixbuf-2.0/loaders.cache"
  export GDK_PIXBUF_MODULE_FILE="$AILIBDIR/gdk-pixbuf-2.0/loaders.cache"
  echo "GDK_PIXBUF_MODULE_FILE: $GDK_PIXBUF_MODULE_FILE"
  #cat $GDK_PIXBUF_MODULE_FILE
}


init_gtk()
{
  init_gdk_pixbuf
export GTK_PATH="$APPDIR/usr/lib/gtk-2.0"
echo "GTK_PATH=${GTK_PATH}"

export GTK_IM_MODULE_FILE="$APPDIR/usr/lib/gtk-2.0:$GTK_PATH"
echo "GTK_IM_MODULE_FILE=${GTK_IM_MODULE_FILE}"

export PANGO_LIBDIR="$APPDIR/usr/lib"
echo "PANGO_LIBDIR=${PANGO_LIBDIR}"
}