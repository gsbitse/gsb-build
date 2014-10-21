#!/bin/sh

############################################
# initialize the distro and acquia urls

project_name=gsb-public
distro_name=$project_name-distro
acquia_name=gsbpublic
distro_url=https://github.com/$project_name/$distro_name.git
publicsite_url=$acquia_name@svn-3224.prod.hosting.acquia.com:$acquia_name.git
publicsite_ssh=$acquia_name@staging-9591.prod.hosting.acquia.com
publicsite_prod_ssh=$acquia_name@ded-1528.prod.hosting.acquia.com

############################################
# save the workspace root directory

workspace_dir=$PWD

############################################
# set the public site ssh to prod if we are
# on prod

if test $server = "prod"
then
  publicsite_ssh=$publicsite_prod_ssh
fi

############################################
# check if the distro branch exists
# if not exit with an error

cd ${workspace_dir}/$distro_name

ret_code=$(git ls-remote $distro_url $branch | wc -l | tr -d ' ')
if [[ $ret_code != 1 ]]; then
    echo "$distro_name branch = $branch not found"
    exit -1
else
    git pull 
fi

############################################
# check if the acquia branch exists
# if not exit with an error

cd ${workspace_dir}/$acquia_name

ret_code=$(git ls-remote $publicsite_url $server | wc -l | tr -d ' ')
if [[ $ret_code != 1 ]]; then
    echo "$acquia_name branch = $server not found"
    exit -1
else
    git pull 
fi

############################################
# check if the gsb-distro directory exists
# if it doesn't clone it

cd $workspace_dir

if [ ! -d $distro_name ]; then
    git clone -b $branch $distro_url
    if [ ! -d $distro_name ]; then
       echo "$distro_name cloned failed for branch = $branch"
       exit -1
    fi
    echo "$distro_name directory created"
else 
    echo "$distro_name directory exists"
fi

############################################
# checkout the gsb-distro branch
# 

cd ${workspace_dir}/$distro_name
git checkout $branch

############################################
# check if the acquia directory exists
# if it doesn't clone it

cd $workspace_dir

if [ ! -d $acquia_name ]; then
    git clone -b $server $publicsite_url 
    if [ ! -d $acquia_name ]; then
       echo "$acquia_name cloned failed for branch = $server"
       exit -1
    fi    
    echo "$acquia_name directory created"
else
    echo "$acquia_name directory exists"
fi

############################################
# checkout the acquia branch
# 

cd ${workspace_dir}/$acquia_name
git checkout $server
git pull

############################################
# change to the acquia directory
# remove the previous files from the docroot
# and then run the drush make

cd ${workspace_dir}/$acquia_name

rm -rf docroot

echo "start drush make"

php /private/stanfordgsb/drush/drush.php make ../$distro_name/$distro_name.make docroot

echo "end drush make"

############################################
# make sure the directory exists before
# continuing.

if [ ! -d docroot ]; then
    echo "The make failed"
    exit -1
fi

############################################
# copy the settings.php file back to 
# the acquia directory 

echo "begin - settings copy"

cp /private/stanfordgsb/settings_$acquia_name_qa.php ${workspace_dir}/$acquia_name/docroot/sites/default/settings.php

if test $server = "prod"
then
  cp /private/stanfordgsb/settings_$acquia_name.php ${workspace_dir}/$acquia_name/docroot/sites/default/settings.php
fi

echo "end - settings copy"

############################################
# create a gsb -> default symlink to 
# create a separate path for files

echo "begin - gsb symlink"

cd ${workspace_dir}/$acquia_name/docroot/sites
ln -s default gsb

echo "end - gsb symlink"

############################################
# remove all the previous files that are
# no longer needed 
# (the files not recreated by the make)

git rm $(git ls-files --deleted)

############################################
# updating symlink for simplesaml

echo "begin - updating symlink for simplesaml"

cd ${workspace_dir}/$acquia_name/docroot

ln -s ../library/simplesamlphp/www simplesaml

echo "end - updating symlink for simplesaml"

############################################
# add the changes up to acquia

echo "begin - $acquia_name add/commit/push"

cd ${workspace_dir}/$acquia_name

git add .
git add -f docroot/sites/default/settings.php
git commit -am "build from cloudbees - project: $acquia_name  branch: $branch server: $server"
git push origin $server

echo "end - $acquia_name add/commit/push"

ssh ${publicsite_ssh} "sh build/bin/acquia-build/build.sh $server"

############################################
# end of build script 
#
