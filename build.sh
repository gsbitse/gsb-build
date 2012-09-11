#!/bin/sh

############################################
# save the workspace root directory

workspace_dir=$PWD

############################################
# check if the gsb-distro directory exists
# if it doesn't clone it

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

############################################
# check if the revamp directory exists
# if it doesn't clone it

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

############################################
# check if the gsb-distro branch exists
# if not checkout the branch

cd ${workspace_dir}/gsb-distro
git show-branch $branch
if [[ $? != 0 ]]; then
    git checkout $branch
    git show-branch $branch
    if [[ $? != 0 ]]; then
        echo "failed to checkout gsb-distro branch = $branch"
        exit -1
    fi    
    echo "gsb-distro checkout branch = $branch" 
else
    git checkout $branch
fi

############################################
# check if the revamp branch exists
# if not checkout the branch

cd ${workspace_dir}/revamp
git show-branch $server
if [[ $? != 0 ]]; then
    git checkout $server
    git show-branch $server
    if [[ $? != 0 ]]; then
        echo "failed to checkout revamp branch = $server"
        exit -1
    fi
    echo "revamp checkout branch = $server"
else
    git checkout $server
fi

############################################
# change to the revamp directory
# and then run the drush make

cd ${workspace_dir}/revamp

rm -rf docroot
php library/drush/drush.php make ../gsb-distro/gsb-public-distro.make docroot

############################################
# add back in the symlink for the files
# directory

# ln -s docroot/sites/default/files /mnt/?????

############################################
# add the changes up to acquia

git add .
git commit -am "build from cloudbees - project: revamp  branch: $branch server: $server"
git push origin $server

############################################
# end of build script 
#

