#!/bin/sh

set -o errexit

VERSION=$(cat $(dirname $0)/VERSION)
BASE_DIR=$(dirname $0)


PREP_TREE=${BASE_DIR}/debwrk
pushd ${BASE_DIR}

if test "$1" = "-c" ; then
  CLEAN=YES
  shift 1
fi

if [ ! -f grass/config.status ]; then
  CLEAN=YES
fi

if test "x$1" = "x" ; then
  echo "Usage: build.sh <packaging>"
  echo
  echo "ie. build.sh [-c] 3pl"
  exit 1
fi

PACKAGING=$1

DEB=grass_${VERSION}-${PACKAGING}_amd64.deb

pushd grass

if test "$CLEAN" = "YES" ; then
  make distclean || echo "distclean failed..."
  ./configure \
      --prefix=/usr \
      --without-opengl \
      --with-freetype-includes=/usr/include/freetype2 \
      --enable-largefile \
      --with-sqlite \
      --without-tcltk
fi

make -j 3 PROJSHARE=/usr/share/proj

rm -rf $PREP_TREE
mkdir -p $PREP_TREE/usr
make install prefix=$PREP_TREE/usr PROJSHARE=/usr/share/proj

popd
#./post_install_fixes.py

sed -i debwrk/usr/bin/grass70 -e "s#$(readlink -f ${BASE_DIR})/debwrk##g"

mkdir -p debwrk/DEBIAN
sed 's/@@@PACKAGING@@@/'$PACKAGING'/g' control.debian > debwrk/DEBIAN/control
sed -i debwrk/DEBIAN/control -e 's/@@@VERSION@@@/'$VERSION'/g'

mkdir -p debwrk/etc/ld.so.conf.d
echo "/usr/grass-${VERSION}/lib" > debwrk/etc/ld.so.conf.d/grass.conf
cp postinst.debian debwrk/DEBIAN/postinst

rm -f grass_*.deb
dpkg-deb --build debwrk $DEB

echo Created: $DEB

cp $DEB $HOME/debs
popd
