#!/usr/bin/env bash

set -e
set -u
set -x

function find_dist() {
    if [ ! -x /usr/bin/lsb_release ]; then
        sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes lsb-release
    fi

    dist=$(lsb_release -c -s)
    _RET=${dist}
}

function fixup_perms() {
    sudo chown ubuntu: -R /opt
}

function setup_common() {
    pushd /opt/planet_common
    /bin/bash -x ./init.sh
    popd
}

function setup_build() {
    # ?!
    [ -d ${HOME}/debs ] && rm -rf ${HOME}/debs
    mkdir -p ${HOME}/debs
    sudo apt-get install -y build-essential devscripts dpkg-dev cmake
}

function build_package() {
    dir=$1
    basename=$2

    pushd "/opt/debuild/${dir}"

    if [ -f debian/changelog ]; then
        # prefer to get version from changelog
        buildver=$(dpkg-parsechangelog | grep Version: | awk '{ print $2 }')
    else
        version=$(cat VERSION)
        build=$(cat BUILD)
        buildver=${version}-${build}
    fi

    candidate_package=${basename}_${buildver}_amd64.deb

    candidate_version=$(apt-cache policy ${basename} | grep Candidate | awk '{ print $2 }')
    if dpkg --compare-versions ${buildver} ge ${candidate_version}; then
        echo "*****************************************************************"
        echo "Building ${basename}: ${candidate_version} -> ${buildver}"
        echo "*****************************************************************"
        echo

        if [ -x ./setup.sh ]; then
            /bin/bash -x ./setup.sh
        fi

        /bin/bash -x ./build.sh -c ${build:-""}
    else
        echo "*****************************************************************"
        echo "Skipping ${basename}: ${candidate_version} -> ${buildver}"
        echo "*****************************************************************"
        echo
    fi
}

function setup_sources() {
    find_dist
    dist=${_RET}

    case ${dist} in
        precise)
            setup_precise_sources
            ;;
        trusty)
            setup_trusty_sources
            ;;
        *)
            echo "Don't know how to build packages for ${dist}"
            exit 1
            ;;
    esac

    sudo rm -rf /etc/apt/sources.list.d/*
    sudo apt-get update -y
}

function setup_precise_sources() {
    cat > /tmp/planet.list <<EOF
deb [arch=amd64] http://planet-ubuntu.s3.amazonaws.com/ubuntu/ precise main restricted
deb [arch=amd64] http://planet-ubuntu.s3.amazonaws.com/ubuntu/ precise-updates main restricted
deb [arch=amd64] http://planet-ubuntu.s3.amazonaws.com/ubuntu/ precise universe
deb [arch=amd64] http://planet-ubuntu.s3.amazonaws.com/ubuntu/ precise-updates universe
deb [arch=amd64] http://planet-ubuntu.s3.amazonaws.com/ubuntu/ precise multiverse
deb [arch=amd64] http://planet-ubuntu.s3.amazonaws.com/ubuntu/ precise-updates multiverse
deb [arch=amd64] http://planet-ubuntu.s3.amazonaws.com/ubuntu/ precise-backports main restricted universe multiverse

deb https://planet-ubuntu.s3.amazonaws.com/68f0d2b37079/ppa/ubuntugis/ubuntugis-unstable/ubuntu/ precise main

deb https://aptly.planet-staging.com/4fc661f6-078a-4c31-bb4d-750f9a124a0e/ precise staging
deb https://apt.planet-staging.com/ubuntu/ ${dist}-backports main restricted universe multiverse
deb https://planet-ubuntu.s3.amazonaws.com/68f0d2b37079/ppa/ubuntugis/ubuntugis-unstable/ubuntu precise main
EOF

    sudo cp /tmp/planet.list /etc/apt/sources.list
}

function setup_trusty_sources() {
    cat > /tmp/planet.list <<EOF
deb https://aptly.planet-staging.com/b79c437d-58be-4ac3-b2b1-b9f333a714af/ trusty staging
EOF
    sudo cp /tmp/planet.list /etc/apt/sources.list.d/planet.list
}

function setup_git() {
    mkdir -p /home/ubuntu/.ssh
    chmod 700 /home/ubuntu/.ssh

    ssh-keyscan -t rsa github.com >> /home/ubuntu/.ssh/known_hosts

    chown -R ubuntu: /home/ubuntu/.ssh
    chmod 600 /home/ubuntu/.ssh/known_hosts

    [ -f /home/ubuntu/.ssh/config ] && rm /home/ubuntu/.ssh/config

    if [ ! -x /usb/bin/git ]; then
        sudo DEBIAN_FRONTEND=noninteractive apt-get install git -y --force-yes
    fi
}

function git_checkout() {
    user=$1
    repo=$2
    branch=$3

    pushd /opt
    if [ -d "${repo}" ]; then
        pushd "${repo}"
        git reset --hard
        git clean -df
        git pull
    else
        git clone git@github.com:${user}/${repo}
        pushd "${repo}"
    fi

    git checkout ${branch}
    popd
    popd
}

basedir=$(dirname $0)

action=$1

sshargs="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ForwardAgent=yes"

case "${action}" in
    deploy)
        ip=$2

        ssh ${sshargs} ubuntu@${ip} 'sudo mkdir -p /opt/ci && sudo chown ubuntu: /opt/ci'
        scp ${sshargs} $0 ubuntu@${ip}:/opt/ci/$(basename $0)
        ssh ${sshargs} ubuntu@${ip} chmod 755 /opt/ci/$(basename $0)
        ;;

    clean)
        ip=$2

        if [ "${ip}" != "remote" ]; then
            ssh ${sshargs} ubuntu@${ip} sudo /opt/ci/$(basename $0) clean remote
        else
            [ -d /opt ] && rm -rf /opt/
            [ -f /home/ubunu/.ssh/known_hosts ] && rm /home/ubuntu/.ssh/known_hosts
            [ -f /root/.ssh/known_hosts ] && rm /root/.ssh/known_hosts
        fi
        ;;

    prep)
        ip=$2

        if [ "${ip}" != "remote" ]; then
            ssh ${sshargs} ubuntu@${ip} /opt/ci/$(basename $0) prep remote
        else
            fixup_perms
            setup_sources
            setup_git
            git_checkout rpedde debuild trusty
            # git_checkout planetlabs planet_common master
            # setup_common
            setup_build
        fi
        ;;

    build)
        ip=$2

        if [ "${ip}" != "remote" ]; then
            ssh ${sshargs} ubuntu@${ip} /opt/ci/$(basename $0) build remote
        else
            build_package wjelement wjelement-pl
            build_package gdal gdal-bin
            build_package gdal_mrsid gdal-mrsid
            build_package gdal_ecw gdal-ecw
            build_package mapserver mapserver-bin
            build_package grass grass

            build_package opencv opencv-pl
            # build_package flann libflann1
        fi
        ;;

    *)
        ;;
esac
