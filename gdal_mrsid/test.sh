#!/bin/sh

sudo dpkg -r gdal-mrsid
sudo dpkg -i ../../debs/gdal-mrsid*.deb

gdalinfo \
    /vsicurl/http://download.osgeo.org/gdal/data/mrsid/lossless-mg3/econic.sid

