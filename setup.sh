#!/bin/bash

if [[ $EUID -eq 0 ]]; then
  echo "do not run this as root!"
  exit 1
fi

# abort install if any errors occur and enable tracing
set -o errexit
set -o xtrace

if test \! -d $HOME/debs ; then
  mkdir $HOME/debs
fi

if test \! -e /vagrant ; then
  sudo ln -s /home/ubuntu /vagrant
fi

