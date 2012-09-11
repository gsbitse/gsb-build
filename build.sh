#!/bin/sh

if [[ ! -e gsb_distro ]]; then
    git clone -b $branch https://github.com/gsbitse/gsb-distro.git
    echo "gsb-distro directory created\n"
fi

if [[ ! -e revamp ]]; then
    git clone -b $branch revamp@svn-634.devcloud.hosting.acquia.com:revamp.git
    echo "revamp directory created\n"
fi

cd gsb-distro
git show-branch $branch
if [[ $? != 0 ]]; then
    git clone -b $branch https://github.com/gsbitse/gsb-distro.git
    echo "gsb-distro branch = $branch was cloned" 
fi

cd ..

cd revamp 

