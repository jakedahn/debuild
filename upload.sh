#!/bin/sh

set -o errexit
set -o xtrace

scp $HOME/debs/*.deb staging@pkg.planet-staging.com:~/
scp $HOME/debs/*.deb staging@aptly.planet-staging.com:~/

ssh staging@pkg.planet-staging.com './sync_staging.sh'
ssh staging@aptly.planet-staging.com './sync_staging.sh'

curl -X POST -n https://jobs.planet-staging.com/v0/workers/trigger_update
