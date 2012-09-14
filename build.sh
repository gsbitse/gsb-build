#!/bin/sh

############################################
# initialize the distro and revamp urls

distro_url="https://github.com/gsbitse/gsb-distro.git"
revamp_url="revamp@svn-634.devcloud.hosting.acquia.com:revamp.git"

############################################
# save the workspace root directory

workspace_dir=$PWD

############################################
# check if the gsb-distro branch exists
# if not exit with an error

ret_code=$(git ls-remote $distro_url $branch | wc -l | tr -d ' ')
if [[ $ret_code != 1 ]]; then
    echo "gsb-distro branch = $branch not found"
    exit -1
fi

############################################
# check if the revamp branch exists
# if not exit with an error

ret_code=$(git ls-remote $revamp_url $server | wc -l | tr -d ' ')
if [[ $ret_code != 1 ]]; then
    echo "revamp branch = $server not found"
    exit -1
fi

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
# checkout the gsb-distro branch
# 

cd ${workspace_dir}/gsb-distro
git checkout $branch

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
# checkout the revamp branch
# 

cd ${workspace_dir}/revamp
git checkout $server

############################################
# copy the settings.php file off to 
# a temp directory

mkdir ${workspace_dir}/temp

cd ${workspace_dir}/revamp
git pull

cp docroot/sites/default/settings.php ${workspace_dir}/temp/.


############################################
# change to the revamp directory
# and then run the drush make

cd ${workspace_dir}/revamp

rm -rf docroot
php library/drush/drush.php make ../gsb-distro/gsb-public-distro.make docroot

############################################
# add back in the symlink for the files
# directory

#ln -s /mnt/files/revamp/sites/default/files docroot/sites/default/files 

############################################
# copy the settings.php file back to 
# the revamp directory 

cd ${workspace_dir}/revamp
cp ${workspace_dir}/temp/settings.php docroot/sites/default/.

############################################
# add the changes up to acquia

cd ${workspace_dir}/revamp

git add .
git commit -am "build from cloudbees - project: revamp  branch: $branch server: $server"
git push origin $server

############################################
# end of build script 
#




