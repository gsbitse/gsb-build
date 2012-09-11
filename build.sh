#!/bin/sh

if [[ ! -e gsb_distro ]]; then
    git clone -b $branch https://github.com/gsbitse/gsb-distro.git
    cd gsb-distro
    git show-branch $branch
    if [[ $? != 0 ]]; then
        echo "failed to clone gsb-distro branch = $branch"
        exit -1
    fi
    cd ..
    echo "gsb-distro directory created"
else 
    echo "gsb-distro directory exists"
fi

if [[ ! -e revamp ]]; then
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
if

cd gsb-distro
git show-branch $branch
if [[ $? != 0 ]]; then
    cd ..
    git clone -b $branch https://github.com/gsbitse/gsb-distro.git
    cd gsb-distro
    git show-branch $branch
    if [[ $? != 0 ]]; then
        echo "failed to clone gsb-distro branch = $branch"
        exit -1
    fi    
    cd ..
    echo "gsb-distro branch = $branch was cloned" 
fi

cd revamp
git show-branch $server
if [[ $? != 0 ]]; then
    cd ..
    git clone -b $server revamp@svn-634.devcloud.hosting.acquia.com:revamp.git
    cd revamp
    git show-branch $server
    if [[ $? != 0 ]]; then
        echo "failed to clone revamp branch = $server"
        exit -1
    fi
    cd ..
    echo "revamp branch = $server was cloned"
fi




