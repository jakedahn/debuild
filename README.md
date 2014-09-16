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

Generally speaking, the newly created .debs are copied to $HOME/debs, and
once you are satisfied they are safe to deploy, you can run upload.sh to 
push them to staging.
```  
  /vagrant/debild/upload.sh
```
There are some idiosyncracies...
