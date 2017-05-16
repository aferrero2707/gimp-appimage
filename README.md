# How to build

Two commands are needed to build and create the AppImage:

    ./build.sh gimp-appimage
    ./mkappimage
    
This will download the source code on work/sources, install them under /zzz, and save the AppImage package in out/

The root password is needed the first time to create the /zzz folder if it does not exist.

# Dependencies

zlib (zlib1g-dev in Ubuntu),
python (libpython-all-dev in Ubuntu),
libffi (libffi-dev in Ubuntu),
libpcre3-dev,
lzma-dev,
libjbig-dev,
libicu-dev,
bison + libbison-dev,
libgmp-dev,
libbzip2-dev
