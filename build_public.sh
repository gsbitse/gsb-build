#!/bin/sh

############################################
# initialize the distro and gsbpublic urls

distro_url="https://github.com/gsbitse/gsb-distro.git"
publicsite_url="gsbpublic@svn-3224.prod.hosting.acquia.com:gsbpublic.git"

publicsite_dev_ssh="gsbpublic@staging-1530.prod.hosting.acquia.com"
publicsite_dev2_ssh="gsbpublic@staging-1530.prod.hosting.acquia.com"
publicsite_stage_ssh="gsbpublic@ded-2036.prod.hosting.acquia.com"
publicsite_stage2_ssh="gsbpublic@ded-2036.prod.hosting.acquia.com"
publicsite_sandbox_ssh="gsbpublic@staging-1530.prod.hosting.acquia.com"
publicsite_loadtest_ssh="gsbpublic@ded-1505.prod.hosting.acquia.com"
publicsite_prod_ssh="gsbpublic@ded-1528.prod.hosting.acquia.com"

############################################
# save the workspace root directory

workspace_dir=$PWD

############################################
# set the public site ssh we will be using
# based on which server we are building on

if test $server = "dev"
then
  publicsite_ssh=$publicsite_dev_ssh
fi

if test $server = "dev2"
then
  publicsite_ssh=$publicsite_dev2_ssh
fi

if test $server = "stage"
then
  publicsite_ssh=$publicsite_stage_ssh
fi

if test $server = "stage2"
then
  publicsite_ssh=$publicsite_stage2_ssh
fi

if test $server = "sandbox"
then
  publicsite_ssh=$publicsite_sandbox_ssh
fi

if test $server = "loadtest"
then
  publicsite_ssh=$publicsite_loadtest_ssh
fi

if test $server = "prod"
then
  publicsite_ssh=$publicsite_prod_ssh
fi

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
# check if the gsbpublic branch exists
# if not exit with an error

cd ${workspace_dir}/gsbpublic

ret_code=$(git ls-remote $publicsite_url $server | wc -l | tr -d ' ')
if [[ $ret_code != 1 ]]; then
    echo "gsbpublic branch = $server not found"
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
# check if the gsbpublic directory exists
# if it doesn't clone it

cd $workspace_dir

if [ ! -d gsbpublic ]; then
    git clone -b $server $publicsite_url 
    if [ ! -d gsbpublic ]; then
       echo "gsbpublic cloned failed for branch = $server"
       exit -1
    fi    
    echo "gsbpublic directory created"
else
    echo "gsbpublic directory exists"
fi

############################################
# checkout the gsbpublic branch
# 

cd ${workspace_dir}/gsbpublic
git checkout $server

############################################
# copy the settings.php file off to 
# a temp directory

# mkdir ${workspace_dir}/temp

cd ${workspace_dir}/gsbpublic
git pull

# cp docroot/sites/default/settings.php ${workspace_dir}/temp/.

############################################
# change to the gsbpublic directory
# remove the previous files from the docroot
# and then run the drush make

cd ${workspace_dir}/gsbpublic

rm -rf docroot

echo "start drush make"

# php /private/stanfordgsb/drush/drush.php vset date_default_timezone 'America/Los_Angeles' -y
php /private/stanfordgsb/drush/drush.php make ../gsb-distro/gsb-public-distro.make docroot

echo "end drush make"

############################################
# add back in the symlink for the files
# directory

#ln -s /mnt/files/gsbpublic/sites/default/files docroot/sites/default/files 

############################################
# copy the settings.php file back to 
# the gsbpublic directory 

echo "begin - settings copy"

cp /private/stanfordgsb/settings_gsbpublic.php ${workspace_dir}/gsbpublic/docroot/sites/default/settings.php

echo "end - settings copy"

############################################
# remove all the previous files that are
# no longer needed 
# (the files not recreated by the make)

git rm $(git ls-files --deleted)

############################################
# updating symlink for simplesaml

echo "begin - updating symlink for simplesaml"

cd ${workspace_dir}/gsbpublic/docroot

ln -s ../library/simplesamlphp/www simplesaml

echo "end - updating symlink for simplesaml"

############################################
# add the changes up to acquia

echo "begin - gsbpublic add/commit/push"

cd ${workspace_dir}/gsbpublic

git add .
git add -f docroot/sites/default/settings.php
git commit -am "build from cloudbees - project: gsbpublic  branch: $branch server: $server rebuild: $rebuild"
git push origin $server

echo "end - gsbpublic add/commit/push"

############################################
# run drush si on acquia site if 
# $rebuild is set to true
#

ssh ${publicsite_ssh} "sh build/build.sh $server $rebuild"

############################################
# end of build script 
#




