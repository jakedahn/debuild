#!/bin/sh

set -o errexit

DEBUILD_TREE=`pwd`

sudo apt-get install -y --force-yes \
    libgd2-xpm-dev libfribidi-dev php5-dev sharutils \
    libsdl1.2-dev libfcgi-dev libogdi3.2-dev libxslt1-dev libpam0g-dev \
    libedit-dev pkg-kde-tools autoconf dh-autoreconf libsvg \
    libsvg-cairo docbook2x docbook-xsl docbook-xml xsltproc \
    swig python-all python-all-dev chrpath \
    libepsilon-dev ruby1.8-dev ruby1.8 ruby1.9.1 ruby1.9.1-dev libgdal1-dev


mkdir -p $HOME/packages/mapserver
cd $HOME/packages/mapserver

VERSION=6.2.1

if test ! -f mapserver-$VERSION.tar.gz; then
    wget http://download.osgeo.org/mapserver/mapserver-$VERSION.tar.gz
fi

if test ! -d mapserver-$VERSION; then
    tar xvzf mapserver-$VERSION.tar.gz
    cd mapserver-$VERSION
    cp -r $DEBUILD_TREE/debian .
fi

echo "Setup appears to be successful."




