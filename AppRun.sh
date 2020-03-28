#!/bin/bash

DIR="`dirname \"$0\"`" 
DIR="`( cd \"$DIR\" && readlink -f $(pwd) )`"
echo "DIR: $DIR"
export APPDIR=$DIR

source "$APPDIR/apprun-helper.sh"
save_environment
make_temp_libdir
link_libraries
echo "AILIBDIR=$AILIBDIR"
#export APPDIR2=$AILIBDIR
fix_libxcb_dri3
fix_stdlibcxx
#fix_fontconfig
fix_library "libfontconfig"
fix_library "libfreetype"


init_environment
export APPDIRS=$AILIBDIR:$AILIBDIR/gimp/2.0/plug-ins:$HOME/.config/GIMP-AppImage/2.10/plug-ins:$APPDIRS
echo "APPDIRS: $APPDIRS"

init_gtk

export PYTHONHOME=$DIR/usr/

export PATH=$DIR/usr/bin:$PATH

export PYTHONPATH=$DIR/usr/share/pyshared/:$(readlink -f "$DIR/usr/lib/gimp/2.0/python"):$PYTHONPATH

#export XDG_CONFIG_DIRS=$DIR/usr/share:$XDG_CONFIG_DIRS

export PERLLIB=$DIR/usr/share/perl5/:$DIR/usr/lib/perl5/:$PERLLIB

export GSETTINGS_SCHEMA_DIR=$DIR/usr/share/glib-2.0/schemas/:$GSETTINGS_SCHEMA_DIR

export BABL_PATH=$(readlink -f "$DIR/usr/lib64/babl-0.1")
echo "BABL_PATH $BABL_PATH"

export GEGL_PATH=$(readlink -f "$DIR/usr/lib64/gegl-0.4")
echo "GEGL_PATH $GEGL_PATH"

mkdir -p "$AILIBDIR/gimp/2.0"

ln -s $(readlink -f "$DIR/usr/lib/gimp/2.0")/* "$AILIBDIR/gimp/2.0"
rm -f "$AILIBDIR/gimp/2.0/interpreters"
cp -a $(readlink -f "$DIR/usr/lib/gimp/2.0")/interpreters "$AILIBDIR/gimp/2.0"
sed -i -e "s|/usr/bin|$DIR/usr/bin|g" "$AILIBDIR/gimp/2.0/interpreters/pygimp.interp"
cat "$AILIBDIR/gimp/2.0/interpreters/pygimp.interp"

rm -f "$AILIBDIR/gimp/2.0/plug-ins"
mkdir -p "$AILIBDIR/gimp/2.0/plug-ins"
ln -s $(readlink -f "$DIR/usr/lib/gimp/2.0/plug-ins")/* "$AILIBDIR/gimp/2.0/plug-ins"
#export GIMP2_PLUGINDIR=$(readlink -f "$DIR/usr/lib/gimp/2.0")
export GIMP2_PLUGINDIR="$AILIBDIR/gimp/2.0"
echo "GIMP2_PLUGINDIR: $GIMP2_PLUGINDIR"

export GIMP2_DATADIR="$DIR/usr/share/gimp/2.0"
export GIMP2_LOCALEDIR="$DIR/usr/share/locale"
export GIMP2_SYSCONFDIR="$DIR/usr/etc/gimp/2.0"

if [ -e /etc/fonts/fonts.conf ]; then
  export FONTCONFIG_PATH=/etc/fonts
fi

run_hooks

load_external_plugins


#cd $DIR/usr

#bin/gimp "$@"; exit

echo "Input parameters: \"$@\""
echo ""
echo "Input File: $1"
ldd $DIR/usr/bin/gimp.bin
echo ""
echo "$DIR/usr/bin/gimp.bin --pdb-compat-mode=on \"$@\""
#gdb -ex "run --pdb-compat-mode=on \"$@\"" $HERE/gimp.bin
#gdb $HERE/gimp.bin
which python
#GDB=$(which gdb)
#echo "Starting GDB ($GDB)"
#$GDB
#echo "GDB finished"

export LD_PRELOAD=$DIR/usr/lib/exec_wrapper.so
$DIR/usr/bin/gimp.wrapper --pdb-compat-mode=on "$@"

rm -rf "$AILIBDIR"
