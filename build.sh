#!/bin/sh

############################################
# initialize the distro and revamp urls

distro_url="https://github.com/gsbitse/gsb-distro.git"
revamp_url="revamp@svn-634.devcloud.hosting.acquia.com:revamp.git"
revamp_ssh="revamp@srv-1353.devcloud.hosting.acquia.com"

############################################
# save the workspace root directory

workspace_dir=$PWD

############################################
# check if the gsb-distro branch exists
# if not exit with an error

cd ${workspace_dir}/gsb-distro

ret_code=$(git ls-remote $distro_url $branch | wc -l | tr -d ' ')
if [[ $ret_code != 1 ]]; then
    echo "gsb-distro branch = $branch not found"
    exit -1
else
    git pull 
fi

############################################
# check if the revamp branch exists
# if not exit with an error

cd ${workspace_dir}/revamp

ret_code=$(git ls-remote $revamp_url $server | wc -l | tr -d ' ')
if [[ $ret_code != 1 ]]; then
    echo "revamp branch = $server not found"
    exit -1
else
    git pull 
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

# mkdir ${workspace_dir}/temp

cd ${workspace_dir}/revamp
git pull

# cp docroot/sites/default/settings.php ${workspace_dir}/temp/.

############################################
# change to the revamp directory
# remove the previous files from the docroot
# and then run the drush make

cd ${workspace_dir}/revamp

rm -rf docroot

echo "start drush make"

# php library/drush/drush.php make ../gsb-distro/gsb-public-distro.make docroot
php /private/stanfordgsb/drush/drush.php make ../gsb-distro/gsb-public-distro.make docroot

echo "end drush make"

############################################
# add back in the symlink for the files
# directory

#ln -s /mnt/files/revamp/sites/default/files docroot/sites/default/files 

############################################
# copy the settings.php file back to 
# the revamp directory 

echo "begin - settings copy"

# cd ${workspace_dir}/revamp
# cp ${workspace_dir}/temp/settings.php docroot/sites/default/.
cp /private/stanfordgsb/settings.php ${workspace_dir}/revamp/docroot/sites/default/.

echo "end - settings copy"

############################################
# remove all the previous files that are
# no longer needed 
# (the files not recreated by the make)

git rm $(git ls-files --deleted)

############################################
# add the changes up to acquia

echo "begin - revamp add/commit/push"

cd ${workspace_dir}/revamp

git add .
git add -f docroot/sites/default/settings.php
git commit -am "build from cloudbees - project: revamp  branch: $branch server: $server"
git push origin $server

echo "end - revamp add/commit/push"

############################################
# run drush si on acquia site if 
# $rebuild is set to true
#

ssh $revamp_ssh "sh build/build.sh $server $rebuild"

############################################
# end of build script 
#




