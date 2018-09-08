#! /bin/bash

#BABL_GIT_TAG=BABL_0_1_56
#GEGL_GIT_TAG=GEGL_0_4_8
#GIMP_GIT_TAG=GIMP_2_10_6

docker run --rm -it -v $(pwd):/sources -e "BABL_GIT_TAG=$BABL_GIT_TAG" -e "GEGL_GIT_TAG=$GEGL_GIT_TAG" -e "GIMP_GIT_TAG=$GIMP_GIT_TAG" photoflow/docker-centos7-gimp bash #/sources/ci/appimage-centos7.sh

