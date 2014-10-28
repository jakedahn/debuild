#!/usr/bin/env python

import os
import sys

grass_script = open('debwrk/usr/bin/grass70').read()

fixed_grass_script = grass_script.replace(
    '/home/ubuntu/debuild/grass/debwrk','')
fixed_grass_script = fixed_grass_script.replace(
    '/vagrant/debuild/grass/debwrk','')

if fixed_grass_script == grass_script:
    print 'Failed to fix grass70 startup script prefix!'
    sys.exit(1)

open('debwrk/usr/bin/grass70','w').write(fixed_grass_script)


