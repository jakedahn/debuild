#!/bin/sh

set -o errexit

if test ! -d wjelement ; then
  git clone https://github.com/netmail-open/wjelement.git
fi
