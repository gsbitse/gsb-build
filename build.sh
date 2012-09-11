#!/bin/sh

if [[ ! -e gsb_distro ]]; then
    git clone -b $branch https://github.com/gsbitse/gsb-distro.git
    echo "gsb-distro directory created"
fi

if [[ ! -e revamp ]]; then
    git clone -b $server revamp@svn-634.devcloud.hosting.acquia.com:revamp.git
    echo "revamp directory created"
fi

cd gsb-distro
git show-branch $branch
if [[ $? != 0 ]]; then
    git clone -b $branch https://github.com/gsbitse/gsb-distro.git
    echo "gsb-distro branch = $branch was cloned" 
fi

cd ..

cd revamp 
git show-branch $server
if [[ $? != 0 ]]; then
    git clone -b $server revamp@svn-634.devcloud.hosting.acquia.com:revamp.git
    echo "revamp branch = $server was cloned"
fi


