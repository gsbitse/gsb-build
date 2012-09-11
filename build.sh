#!/bin/sh

if [[ ! -e gsb-build ]]; then
    echo "directory gsb-build does not exist\n"
    exit -1
fi

if [[ ! -e gsb_distro ]]; then
    git clone https://github.com/gsbitse/gsb-distro.git
    echo "gsb-distro directory created\n"
else
    echo "gsb-distro directory exists\n"
fi


