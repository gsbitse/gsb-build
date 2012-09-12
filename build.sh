#!/bin/sh

############################################
# initialize the distro and revamp urls

distro_url="https://github.com/gsbitse/gsb-distro.git"
revamp_url="revamp@svn-634.devcloud.hosting.acquia.com:revamp.git"

############################################
# save the workspace root directory

workspace_dir=$PWD

############################################
# check if the gsb-distro directory exists
# if it doesn't clone it

cd $workspace_dir

if [ ! -d gsb-distro ]; then
    git clone -b $branch $distro_url
    if [ ! -d gsb-distro ]; then
       echo "gsb-distro cloned failed for branch = $branch"
       exit -1
    fi
    echo "gsb-distro directory created"
else 
    echo "gsb-distro directory exists"
fi
