[![Build Status](https://github.com/aferrero2707/gimp-appimage/actions/workflows/ci.yml/badge.svg)](https://github.com/aferrero2707/gimp-appimage/actions/workflows/ci.yml)

# Introduction

The GIMP AppImage is built on CentOS 7, using a custom [Docker container](https://github.com/aferrero2707/docker-centos7-gimp) that provides all the required up-to-date dependencies.

The compilation of the BABL/GEGL/GIMP code under Docker is performed by the [build-appimage-centos7.sh](https://github.com/aferrero2707/gimp-appimage/blob/master/build-appimage-centos7.sh) shell script, while the [AppImage](https://appimage.org) bundle is created and packaged by the [package-appimage.sh](https://github.com/aferrero2707/gimp-appimage/blob/master/package-appimage.sh) script.

A second step in the build process compiles a set of useful plug-ins ([build-appimage-plugins-centos7.sh](https://github.com/aferrero2707/gimp-appimage/blob/master/build-appimage-plugins-centos7.sh)), which are then bundled into an additional, full-featured AppImage package.

The whole build process is automated with [Travis CI](https://travis-ci.org/aferrero2707/gimp-appimage), using [this configuration file](https://github.com/aferrero2707/gimp-appimage/blob/master/.travis.yml). A cron job is scheduled to run on a weekly basis and builds the git HEAD version of BABL/GEGL/GIMP. The updated AppImage package is automatically uploaded to the [continuous release page](https://github.com/aferrero2707/gimp-appimage/releases/tag/continuous).

# GIMP plug-ins

Several GIMP plug-ins that can work in combination with the AppImage can be downloaded from [here](https://github.com/aferrero2707/gimp-plugins-collection/releases/tag/continuous).

This is the current list of available plug-ins:
* [Resynthesizer](http://registry.gimp.org/node/25219) - texture synthesis
* [Liquid rescale](http://liquidrescale.wikidot.com/) - content-aware image resizing based on seam carving
* [NUfraw](https://sourceforge.net/projects/nufraw/) - RAW image processing
* [G'MIC-Qt](https://gmic.eu/gimp.shtml) - the plug-in for the G'MIC filters library
* [PhFGIMP](https://github.com/aferrero2707/PhFGimp) - front-end for the PhotoFlow editor

Follow the instructions in the plug-ins release page to install them in your system.

# Credits

The AppImage uses a modified version of the exec-wrapper originally available from here:

    https://github.com/TheAssassin/linuxdeploy-plugin-checkrt
    
It allows GIMP to spawn external commands with the original shell environment instead of the one proper to the AppImage itself. 
