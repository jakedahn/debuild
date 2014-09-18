#!/bin/sh

set -o errexit

GDALBLD=$HOME/packages/gdal/gdal
MRSIDSDK=`pwd`/MrSID-Raster-8.5.0

if test "x$1" = "x" ; then
  echo "Usage: build.sh <packaging>"
  echo
  echo "ie. build.sh [-c] 3pl"
  exit 1
fi

PACKAGING=$1

if test `lsb_release -c | cut -f 2` != 'precise' ; then
  echo "Not running on Ubuntu precise, shouldn't you be?"
  exit 1
fi

if test ! -f $GDALBLD/.libs/libgdal.so ; then
  echo "GDAL does not appear to be built at $GDALBLD"
  exit 1
fi

cd mrsid

svn update

gcc \
    -shared \
    -fPIC -DHAVE_SSE_AT_COMPILE_TIME  -Wall -DOGR_ENABLED  \
    -Wno-deprecated-declarations \
    -DMRSID_J2K -D_REENTRANT  \
    -I$GDALBLD/port -I$GDALBLD/gcore -I$GDALBLD/alg -I$GDALBLD/ogr \
    -I$GDALBLD/ogr/ogrsf_frmts \
    -I$MRSIDSDK/include -I/usr/include/geotiff \
    mrsiddataset.cpp mrsidstream.cpp \
    -L$GDALBLD/.libs -lgdal \
    -L$MRSIDSDK/lib -lltidsdk -lgeotiff \
    -o gdal_MrSID.so

DEB=gdal-mrsid_1.11.0-${PACKAGING}_amd64.deb

rm -rf debwrk

mkdir debwrk

mkdir -p debwrk/usr/lib/gdalplugins/1.11
cp gdal_MrSID.so debwrk/usr/lib/gdalplugins/1.11

mkdir -p debwrk/usr/lib
cp $MRSIDSDK/lib/libltidsdk.so.8 debwrk/usr/lib
(cd debwrk/usr/lib ; ln -s libltidsdk.so.8 libltidsdk.so)

mkdir -p debwrk/DEBIAN
sed 's/@@@PACKAGING@@@/'$PACKAGING'/g' ../control.debian > debwrk/DEBIAN/control

rm -f $DEB
dpkg-deb --build debwrk $DEB

echo Created: $DEB

ls -l *.deb
rm -f $HOME/debs/gdal-mrsid*.deb
mv *.deb $HOME/debs


