#!/bin/sh

set -o errexit

if test `lsb_release -c | cut -f 2` != 'precise' ; then
  echo "Not running on Ubuntu precise, shouldn't you be?"
  exit 1
fi

PREP_TREE=`pwd`/debwrk

if test "$1" = "-c" ; then
  CLEAN=YES
  shift 1
fi
if test  \! -f grass/config.status ; then
  CLEAN=YES
fi

if test "x$1" = "x" ; then
  echo "Usage: build.sh <packaging>"
  echo
  echo "ie. build.sh [-c] 3pl"
  exit 1
fi

PACKAGING=$1
DEB=grass_7.0.svn-${PACKAGING}_amd64.deb

cd grass

if test "$CLEAN" = "YES" ; then
  make distclean || echo "distclean failed..."
  ./configure \
      --prefix=/usr \
      --without-opengl \
      --with-freetype-includes=/usr/include/freetype2 \
      --enable-largefile \
      --without-tcltk
fi

make -j 3 PROJSHARE=/usr/share/proj

rm -rf $PREP_TREE
mkdir -p $PREP_TREE/usr
make install prefix=$PREP_TREE/usr PROJSHARE=/usr/share/proj

cd ..
./post_install_fixes.py

mkdir -p debwrk/DEBIAN
sed 's/@@@PACKAGING@@@/'$PACKAGING'/g' control.debian > debwrk/DEBIAN/control

rm -f grass_*.deb
dpkg-deb --build debwrk $DEB

echo Created: $DEB

cp $DEB $HOME/debs





