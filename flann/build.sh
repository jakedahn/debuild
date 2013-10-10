#!/bin/bash

set -o errexit

VERSION=1.8.4

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

FLANN_URL=http://images.notprod.pl/flann-${VERSION}-src.tgz

FLANN_TGZ=`basename $FLANN_URL`
FLANN_SRC=`basename $FLANN_TGZ .tgz`

# only download flann tgz if we haven't already
if [ ! -f $FLANN_TGZ ]; then
  curl $FLANN_URL -o $FLANN_TGZ
  # if we download a new TGZ, make sure the old unziped version was deleted
  rm -rf $FLANN_SRC
fi

# only extract flann tgz to /tmp if we haven't already
if [ ! -d $FLANN_SRC ]; then
  tar zxf $FLANN_TGZ
fi

sudo apt-get install -y --force-yes \
    autoconf2.13 cmake curl make libhdf5-serial-dev \
    libgtest-dev latex2html

PREP_TREE=`pwd`/debwrk

DEB=flann-pl_${VERSION}-${PACKAGING}_amd64.deb

if test \! -f cmake_config.log ; then
  CLEAN=YES
fi

cd $FLANN_SRC

if test "$CLEAN" = "YES" ; then
  cmake \
      -D CMAKE_INSTALL_PREFIX=$PREP_TREE/usr/local/pl \
      -D LATEX_OUTPUT_PATH=/tmp \
      . \
      |& tee ../cmake_config.log
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

rm -f flann-pl*.deb
dpkg-deb --build debwrk $DEB

echo Created: $DEB

cp $DEB $HOME/debs





