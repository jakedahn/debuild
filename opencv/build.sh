#!/bin/bash

set -o errexit

VERSION=2.4.6.1

if test `lsb_release -c | cut -f 2` != 'precise' ; then
  echo "Not running on Ubuntu precise, shouldn't you be?"
  exit 1
fi

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

DEBUILD_TREE=`pwd`

OPENCV_URL=http://images.notprod.pl/opencv-$VERSION.tar.gz

OPENCV_TGZ=`basename $OPENCV_URL`
OPENCV_SRC=`basename $OPENCV_TGZ .tar.gz`

# only download opencv tgz if we haven't already
if [ ! -f $OPENCV_TGZ ]; then
  curl $OPENCV_URL -o $OPENCV_TGZ
  # if we download a new TGZ, make sure the old unziped version was deleted
  rm -rf $OPENCV_SRC
fi

# only extract opencv tgz to /tmp if we haven't already
if [ ! -d $OPENCV_SRC ]; then
  tar zxf $OPENCV_TGZ
fi

sudo apt-get install -y --force-yes \
    autoconf2.13 cmake curl make

PREP_TREE=`pwd`/debwrk

DEB=opencv-pl_${VERSION}-${PACKAGING}_amd64.deb

if test \! -f cmake_config.log ; then
  CLEAN=YES
fi

cd $OPENCV_SRC

if test "$CLEAN" = "YES" ; then
  cmake -D CMAKE_INSTALL_PREFIX=$PREP_TREE/usr . |& tee ../cmake_config.log
  make clean
fi

make

rm -rf $PREP_TREE
mkdir -p $PREP_TREE/usr

make install

cd ..

mkdir -p debwrk/DEBIAN
sed 's/@@@PACKAGING@@@/'$PACKAGING'/g' control.debian \
    | sed 's/@@@VERSION@@@/'$VERSION'/g' \
    > debwrk/DEBIAN/control

rm -f grass_*.deb
dpkg-deb --build debwrk $DEB

echo Created: $DEB

cp $DEB $HOME/debs





