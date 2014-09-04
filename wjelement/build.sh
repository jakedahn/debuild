#!/bin/bash

set -o errexit
set -o xtrace

VERSION=1.0.1
PREP_TREE=`pwd`/debwrk

if test `lsb_release -c | cut -f 2` != 'precise' ; then
  echo "Not running on Ubuntu precise, shouldn't you be?"
  exit 1
fi

CLEAN=NO
if test "$1" = "-c" ; then
  CLEAN=YES
  shift 1
fi

if test "x$1" = "x" ; then
  echo "Usage: build.sh [-c] <packaging>"
  echo
  echo "ie. build.sh [-c] 3pl"
  exit 1
fi

PACKAGING=$1
DEB=wjelement-pl_${VERSION}-${PACKAGING}_amd64.deb

cd wjelement
git pull

if test ! -f Makefile -o "$CLEAN" = "YES" ; then
  cmake \
      -D CMAKE_INSTALL_PREFIX=$PREP_TREE/usr/local/pl \
      -D CMAKE_BUILD_TYPE=Release \
      .
fi


if test "$CLEAN" = "YES" ; then
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
mkdir -p debwrk/etc/ld.so.conf.d
echo "/usr/local/pl/lib" > debwrk/etc/ld.so.conf.d/wjelement.conf
cp postinst.debian debwrk/DEBIAN/postinst

rm -f *.deb
dpkg-deb --build debwrk $DEB

echo Created: $DEB

cp $DEB $HOME/debs





