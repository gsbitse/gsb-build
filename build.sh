#!/bin/sh

workspace_dir=$PWD

cd $workspace_dir

if [ ! -d gsb-distro ]; then
    git clone -b $branch https://github.com/gsbitse/gsb-distro.git
    cd gsb-distro
    git show-branch $branch
    if [[ $? != 0 ]]; then
        echo "failed to clone gsb-distro branch = $branch"
        exit -1
    fi
    echo "gsb-distro directory created"
else 
    echo "gsb-distro directory exists"
fi

cd $workspace_dir

if [ ! -d revamp ]; then
    git clone -b $server revamp@svn-634.devcloud.hosting.acquia.com:revamp.git
    cd revamp
    git show-branch $server
    if [[ $? != 0 ]]; then
        echo "failed to clone revamp branch = $server"
        exit -1
    fi    
    echo "revamp directory created"
else
    echo "revamp directory exists"
fi

cd ${workspace_dir}/gsb-distro
git show-branch $branch
if [[ $? != 0 ]]; then
    git checkout $branch
    cd gsb-distro
    git show-branch $branch
    if [[ $? != 0 ]]; then
        echo "failed to checkout gsb-distro branch = $branch"
        exit -1
    fi    
    echo "gsb-distro checkout branch = $branch" 
fi

cd ${workspace_dir}/revamp
git show-branch $server
if [[ $? != 0 ]]; then
    git checkout $server
    cd revamp
    git show-branch $server
    if [[ $? != 0 ]]; then
        echo "failed to checkout revamp branch = $server"
        exit -1
    fi
    echo "revamp checkout branch = $server"
fi

cd $workspace_dir


