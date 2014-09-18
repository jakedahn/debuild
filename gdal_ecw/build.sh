#!/bin/sh

set -o errexit

GDALBLD=$HOME/packages/gdal/gdal
ECWSDK=`pwd`/ecwjp2_sdk_minimal

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

cd ecw

svn update

gcc \
    -shared \
    -fPIC -DHAVE_SSE_AT_COMPILE_TIME  -Wall \
    -DFRMT_ecw -DOGR_ENABLED \
    -DHAVE_ECW_BUILDNUMBER_H -DLINUX -DX86 -DPOSIX \
    -I$GDALBLD/port -I$GDALBLD/gcore -I$GDALBLD/ogr \
    -I$ECWSDK/include \
    ecwdataset.cpp ecwcreatecopy.cpp jp2userbox.cpp ecwasyncreader.cpp \
    -L$GDALBLD/.libs -lgdal \
    -L$ECWSDK/redistributable/x64 -lNCSEcw \
    -o gdal_ECW.so

DEB=gdal-ecw_1.11.0-${PACKAGING}_amd64.deb

rm -rf debwrk

mkdir debwrk

mkdir -p debwrk/usr/lib/gdalplugins/1.11
cp gdal_ECW.so debwrk/usr/lib/gdalplugins/1.11

mkdir -p debwrk/usr/lib
cp $ECWSDK/redistributable/x64/libNCSEcw.so.5.0.1 debwrk/usr/lib
(cd debwrk/usr/lib ; ln -s libNCSEcw.so.5.0.1 libNCSEcw.so.5)
(cd debwrk/usr/lib ; ln -s libNCSEcw.so.5.0.1 libNCSEcw.so)

mkdir -p debwrk/DEBIAN
sed 's/@@@PACKAGING@@@/'$PACKAGING'/g' ../control.debian > debwrk/DEBIAN/control

rm -f $DEB
dpkg-deb --build debwrk $DEB

echo Created: $DEB

ls -l *.deb
rm -f $HOME/debs/gdal-ecw*.deb
mv *.deb $HOME/debs


