# How to build

The build environment for the GIMP AppImage is based on [jhbuild](https://github.com/GNOME/jhbuild).

However, there is no need to manually install jhbuild, as the build scripts will take care of that automatically.

The creation of the AppImage proceeds in three steps:

1. installation of Python 2.7 and jhbuild:

    ./bootstrap.sh
    
The bootstrap.sh command will ask for the root password in order to create the special /zzz folder under which all software will be installed

2. compilation of GIMP, all its dependencies and all plug-ins with jhbuild:

    ./build.sh gimp-appimage

3. creation of the AppImage itself:

    ./mkappimage
    
The last two steps will download the source code on work/sources, install them under /zzz, and save the AppImage package in out/

# Dependencies

zlib (zlib1g-dev in Ubuntu),
python (libpython-all-dev in Ubuntu),
python-dev (for python-config)
libffi (libffi-dev in Ubuntu),
libpcre3-dev,
lzma-dev,
libjbig-dev,
libicu-dev,
bison + libbison-dev,
libgmp-dev,
libbzip2-dev

# Credits

The AppImage uses the exec-wrapper originally developed by the KDE team:

    git://anongit.kde.org/scratch/brauch/appimage-exec-wrapper
    
It allows GIMP to spawn external commands with the original shell environment instead of the one propoer to the AppImage itself. 
