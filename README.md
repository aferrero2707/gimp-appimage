[![Build Status](https://travis-ci.org/aferrero2707/gimp-appimage.svg?branch=master)](https://travis-ci.org/aferrero2707/gimp-appimage)

# Introduction

The GIMP AppImage is built on Ubuntu 14.04, using a custom [Docker container](https://github.com/aferrero2707/docker-trusty-gimp) that provides all the required up-to-date dependencies. The build environment in the Docker container is based on [jhbuild](https://github.com/GNOME/jhbuild).

The compilation of the BABL/GEGL/GIMP code under Docker is performed by the [build-appimage.sh](https://github.com/aferrero2707/gimp-appimage/blob/master/build-appimage.sh) shell script, which takes care of compiling the programs and then invokes the [mkappimage](https://github.com/aferrero2707/gimp-appimage/blob/master/mkappimage) script for creatig the AppImage bundle.

The final packaging of the AppImage is performed by [package-appimage.sh](https://github.com/aferrero2707/gimp-appimage/blob/master/package-appimage.sh), which gets executed outside of the Docker container.

The whole build process is automated with [Travis CI](https://travis-ci.org/aferrero2707/gimp-appimage), using [this configuration file](https://github.com/aferrero2707/gimp-appimage/blob/master/.travis.yml). A cron job is scheduled to run on a weekly basis and builds the git HEAD version of BABL/GEGL/GIMP. The updated AppImage package is automatically uploaded to the [continuous release page](https://github.com/aferrero2707/gimp-appimage/releases/tag/continuous).

# Included GIMP plug-ins

The AppImages package comes with few useful plug-ins:
* [Resynthesizer](http://registry.gimp.org/node/25219) - texture synthesis
* [Liquid rescale](http://liquidrescale.wikidot.com/) - content-aware image resizing based on seam carving
* [NUfraw](https://sourceforge.net/projects/nufraw/) - RAW image processing
* [G'MIC-Qt](https://gmic.eu/gimp.shtml) - the plug-in for the G'MIC filters library
* [PhFGIMP](https://github.com/aferrero2707/PhFGimp) - front-end for the PhotoFlow editor

# Credits

The AppImage uses the exec-wrapper originally developed by the KDE team:

    git://anongit.kde.org/scratch/brauch/appimage-exec-wrapper
    
It allows GIMP to spawn external commands with the original shell environment instead of the one proper to the AppImage itself. 
