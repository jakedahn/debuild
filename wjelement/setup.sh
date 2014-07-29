#!/bin/sh

set -o errexit

if test ! -d wjelement ; then
  git clone https://github.com/planetlabs/wjelement.git
fi
