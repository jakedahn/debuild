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

FLAGS="-b -j5 -uc -us"
if test "$1" != "-c" ; then
  FLAGS="$FLAGS -nc"
else
  shift 1
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

cp -r $ORIG_DIR/debian $HOME/packages/gdal/gdal

cd $HOME/packages/gdal/gdal

# Make sure we are picking up the latest and greatest.
svn update

# Force some lightweight things to get redone even if we aren't doing a 
# clean build.
rm -f build-stamp
rm -rf debian/tmp
# GDAL isn't good at rebuilding failed python builds.
rm -rf swig/python/build

echo 
echo dpkg-buildpackage $FLAGS
echo

dpkg-buildpackage $FLAGS

if $ORIG_DIR/testpackage.py ; then
  echo "Copy .debs to $HOME/debs"
  cp ../*.deb $HOME/debs
else
  echo "Job FAILED, no .debs copied."
  exit 1
fi
