#!/bin/bash

set -e
set -u

VERSION=$(cat $(dirname $0)/VERSION)


if test "$1" = "-c" ; then
  CLEAN=YES
  shift 1
fi

if test "x$1" = "x" ; then
  echo "Usage: build.sh <packaging>"
  echo
  echo "ie. build.sh [-c] 3pl"
  exit 1
fi

PACKAGING=$1

DEBUILD_TREE=$(readlink -f $(dirname $0))


#OPENCV_URL=/home/ubuntu/opencv-${VERSION}${SETH}.tar.gz
OPENCV_URL=https://github.com/Itseez/opencv/archive/3.0.0-alpha.tar.gz

OPENCV_TGZ=${DEBUILD_TREE}/opencv-$(basename $OPENCV_URL)
OPENCV_SRC=${DEBUILD_TREE}/$(basename $OPENCV_TGZ .tar.gz)

# only download opencv tgz if we haven't already
if [ ! -f $OPENCV_TGZ ]; then
    wget $OPENCV_URL -O ${OPENCV_TGZ}
    # if we download a new TGZ, make sure the old unziped version was deleted
    rm -rf $OPENCV_SRC
fi

# only extract opencv tgz to /tmp if we haven't already
if [ ! -d $OPENCV_SRC ]; then
  tar zxf $OPENCV_TGZ
fi

sudo apt-get install -y --force-yes \
    autoconf2.13 cmake curl make

PREP_TREE=${DEBUILD_TREE}/debwrk

DEB=opencv-pl_${VERSION}-${PACKAGING}_amd64.deb

if test \! -f cmake_config.log ; then
  CLEAN=YES
fi

pushd $OPENCV_SRC

if test "$CLEAN" = "YES" ; then
  cmake -D CMAKE_INSTALL_PREFIX=$PREP_TREE/usr/local/pl . |& tee ../cmake_config.log
  make clean
fi

make

rm -rf $PREP_TREE
mkdir -p $PREP_TREE/usr/local/pl

make install

popd

mkdir -p debwrk/DEBIAN
sed 's/@@@PACKAGING@@@/'$PACKAGING'/g' control.debian \
    | sed 's/@@@VERSION@@@/'$VERSION'/g' \
    > debwrk/DEBIAN/control
mkdir -p debwrk/etc/ld.so.conf.d
echo "/usr/local/pl/lib" > debwrk/etc/ld.so.conf.d/opencv.conf
cp postinst.debian debwrk/DEBIAN/postinst

rm -f opencv-pl*.deb
dpkg-deb --build debwrk $DEB

echo Created: $DEB

cp $DEB $HOME/debs
