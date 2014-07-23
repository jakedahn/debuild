#!/bin/sh

DEBUILD_TREE=`pwd`

sudo apt-get install -y --force-yes \
    python-all-dev doxygen debhelper libpoppler-private-dev \
    liblzma-dev libopenjpeg-dev libarmadillo-dev libfreexl-dev \
    libkml-dev liburiparser-dev netcdf-bin swig chrpath \
    libproj-dev libepsilon-dev d-shlibs \
    libjpeg-dev libpng-dev libnetcdf-dev libjasper-dev \
    unixodbc-dev libgif-dev libgeos-dev libmysqlclient-dev \
    libsqlite3-dev libdap-dev libxml2-dev libspatialite-dev \
    libhdf4-alt-dev libhdf5-serial-dev libpq-dev libxerces-c-dev \
    python-numpy subversion

# dpkg-buildpackage seems to require the pip version or something.
sudo apt-get remove python-setuptools

mkdir -p $HOME/packages/gdal
cd $HOME/packages
if test ! -d gdal ; then
  mkdir gdal
fi
cd gdal
if test ! -d gdal ; then
  svn checkout http://svn.osgeo.org/gdal/branches/1.11/gdal
  cd gdal
  ln -s $DEBUILD_TREE/debian
fi

