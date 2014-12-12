#!/bin/sh

sudo dpkg -r gdal-ecw
sudo dpkg -i $HOME/debs/gdal-ecw*.deb

gdalinfo /vsicurl/http://download.osgeo.org/gdal/data/ecw/spif83.ecw

