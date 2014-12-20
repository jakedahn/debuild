debuild
=======

This contains scripts and stuff needed to build some custom .deb's needed
at Planet Labs.  Also a few notes here on how debian related stuff works.

The "debuild" repo is normally utilized from within a "planet_common" vagrant
environment.  Check out debuild in /vagrant. 

```
  cd /vagrant
  git clone git@github.com:planetlabs/debuild.git debuild
  debuild/setup.sh
```

Each of the deb subprojects should have a setup.sh script that needs to be
run once to install required dev environment components, and a build script 
for building the actual deb.  In most cases the build.sh takes as an argument
the build name.  Identifying the next build name is sometimes a hassle.  

```
  cd /vagrant/debuild/wjelement
  ./setup.sh
  ./build.sh 3pl
```

Generally speaking, the newly created .debs are copied to $HOME/debs (be sure
to examine its content since previous .debs can be accumulated there), and
once you are satisfied they are safe to deploy, you can run upload.sh to 
push them to staging.  Note that in order to do this you will need to ssh
into the vagrant VM in such a way that your keys (access pkg.planet-staging.com)
is carried in.

```  
  vagrant ssh -- -A 
  /vagrant/debuild/upload.sh
```

There are some idiosyncracies...

MapServer build
===============

```
  cd /vagrant/debuild/mapserver
  ./setup.sh
  ./build.sh [-c]
```

The build actually takes place in $HOME/packages/mapserver/mapserver-6.2.1,
into which /vagrant/debuild/mapserver/debian is copied each time ./build.sh is
run. So do not edit directly into $HOME/packages/mapserver/mapserver-6.2.1/debian.
Each time a new build is made the debuild/mapserver/debian/changelog should be updated
to increase the version number.

The -c flag of build.sh causes a clean build, otherwise only an incremental one
will be done.

In case of issues, deleting $HOME/packages/mapserver and running again ./setup.sh
might be helpful.

GDAL build
==========

```
  cd /vagrant/debuild/gdal
  ./setup.sh
  ./build.sh [-c]
```

The build actually takes place in $HOME/packages/gdal/gdal,
into which /vagrant/debuild/gdal/debian is copied each time ./build.sh is
run. So do not edit directly into $HOME/packages/gdal/gdal/debian.

The -c flag of build.sh causes a clean build, otherwise only an incremental one
will be done. build.sh updates the GDAL sources from the GDAL subversion trunk
(2.0dev at that time).
Each time a new build is made the debuild/gdal/debian/changelog should be updated
to increase the version number.

In case of issues, deleting $HOME/packages/gdal and running again ./setup.sh
might be helpful.

After upgrading and uploading GDAL to a new version with incompatible C++ ABI,
a dummy commit touching the following components must be done to force a rebuild:  
  - planet_common/cplusplus/gdal_cmo
  - planet_common/cplusplus/gcps2rpc
  - planet_common/cplusplus/cloudmask
  - plcompositor
The GDAL ECW and MrSID plugins must also be rebuilt

GRASS build
===========

```
  cd /vagrant/debuild/grass
  ./setup.sh
  ./build.sh [-c] Xpl
```

The build actually takes place in /vagrant/debuild/grass.

The -c flag of build.sh causes a clean build, otherwise only an incremental one
will be done.

After upgrading and uploading GRASS, a dummy commit touching the following
components must be done to force GRASS to be updated on Jenkins:  
  - programs/rectify/grass-modules.yml
  - programs/rectify/worker-rectify.yml

