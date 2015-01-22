#!/bin/sh

set -o errexit

DEBUILD_TREE=`pwd`
UPSTREAM_TARBALL=http://grass.osgeo.org/grass70/source/grass-7.0.0RC1.tar.gz

TARBALL=`basename $UPSTREAM_TARBALL`
if test ! -f $TARBALL ; then
  curl $UPSTREAM_TARBALL -o $TARBALL
fi

if test ! -d grass ; then
  tar xf $DEBUILD_TREE/$TARBALL
  mv `basename $TARBALL .tar.gz` grass

  # This avoids linking against a full library path making things non-movable
  #patch -p0 < patches/VECTORDEPS.patch
  patch -p0 < patches/suppress_metadata_r_out_gdal.patch
fi

sudo apt-get install -y --force-yes \
    autoconf2.13 flex bison graphviz libcairo2-dev \
    libfftw3-dev libglu1-mesa-dev libtiff-dev libncurses5-dev \
    libxmu-dev python-wxgtk2.8 libwxgtk2.8-dev tcl-dev tk-dev \
    libsqlite0-dev sqlite

sudo apt-get install -y --force-yes \
    proj-bin libproj-dev libgdal1-dev libgeotiff-dev \
    fftw-dev libfreetype6-dev python-dateutil python-gdal gdal-bin
