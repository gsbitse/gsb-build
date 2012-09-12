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

############################################
# check if the gsb-distro branch exists
# if it does then check it out

cd ${workspace_dir}/gsb-distro

ret_code=$(git ls-remote $distro_url $branch | wc -l)

if [[ ret_code == 0 ]]; then
    git checkout $server
    echo "gsb-distro checkout branch = $branch"
else
    echo "gsb-distro branch = $branch not found"
    exit -1
fi

############################################
# check if the revamp directory exists
# if it doesn't clone it

cd $workspace_dir

if [ ! -d revamp ]; then
    git clone -b $server $revamp_url 
    if [ ! -d revamp ]; then
       echo "revamp cloned failed for branch = $server"
       exit -1
    fi    
    echo "revamp directory created"
else
    echo "revamp directory exists"
fi

############################################
# check if the revamp branch exists
# if it does then check it out

cd ${workspace_dir}/revamp

ret_code=$(git ls-remote $revamp_url $server | wc -l)

if [[ ret_code == 0 ]]; then
    git checkout $server
    echo "revamp checkout branch = $server"
else
    echo "revamp branch = $server not found"
    exit -1
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

