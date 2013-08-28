#!/bin/sh

set -o errexit

if test `lsb_release -c | cut -f 2` != 'precise' ; then
  echo "Not running on Ubuntu precise, shouldn't you be?"
  exit 1
fi

FLAGS="-b -j5 -uc -us"
if test "$1" != "-c" ; then
  FLAGS="$FLAGS -nc"
else
  shift 1
fi

ORIG_DIR=`pwd`

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
  echo "Copy .debs to /vagrant/debs"
  cp ../*.deb /vagrant/debs
else
  echo "Job FAILED, no .debs copied."
  exit 1
fi
