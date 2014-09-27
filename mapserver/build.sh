#!/bin/sh

set -o errexit

if test `lsb_release -c | cut -f 2` != 'precise' ; then
  echo "Not running on Ubuntu precise, shouldn't you be?"
  exit 1
fi

if test "$1" = "-h" -o "$1" = "--help"; then
    echo "Usage: ./build.sh [-c]"
    echo ""
    echo "Options:"
    echo "  -c : do a clean build"
    exit 1
fi

ORIG_DIR=`dirname $0`
case $ORIG_DIR in
    "/"*)
        ;;
    ".")
        ORIG_DIR=`pwd`
        ;;
    *)
        ORIG_DIR=`pwd`"/"`dirname $0`
        ;;
esac

BUILD_DIR=$HOME/packages/mapserver/mapserver-6.2.1

FLAGS="-b -j5 -uc -us"
if test "$1" != "-c" ; then
  FLAGS="$FLAGS -nc"
else
  shift 1
fi

cp -r $ORIG_DIR/debian $BUILD_DIR

cd $BUILD_DIR

# Force some lightweight things to get redone even if we aren't doing a 
# clean build.
rm -f build-stamp
rm -rf debian/tmp

echo 
echo dpkg-buildpackage $FLAGS
echo

dpkg-buildpackage $FLAGS

echo "Copy .debs to $HOME/debs"
cp ../*.deb $HOME/debs
