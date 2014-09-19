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

The -c flag of build.sh causes a clean build, otherwise only an incremental one
will be done.

In case of issues, deleting $HOME/packages/mapserver and running again ./setup.sh
might be helpful.
