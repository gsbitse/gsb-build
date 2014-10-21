#!/bin/sh

############################################
# initialize the distro and gsbpublic urls

distro_url="https://github.com/gsb-public/gsb-public-distro.git"
publicsite_url="gsbpublic@svn-3224.prod.hosting.acquia.com:gsbpublic.git"

publicsite_dev_ssh="gsbpublic@staging-1530.prod.hosting.acquia.com"
publicsite_dev2_ssh="gsbpublic@staging-1530.prod.hosting.acquia.com"
publicsite_stage_ssh="gsbpublic@ded-2036.prod.hosting.acquia.com"
publicsite_stage2_ssh="gsbpublic@ded-2036.prod.hosting.acquia.com"
publicsite_sandbox_ssh="gsbpublic@staging-1530.prod.hosting.acquia.com"
publicsite_loadtest_ssh="gsbpublic@ded-1505.prod.hosting.acquia.com"
publicsite_prod_ssh="gsbpublic@ded-1528.prod.hosting.acquia.com"

#change this to prod... after testing
server="prod"

############################################
# save the workspace root directory

workspace_dir=$PWD

############################################
# cleanup the ssh known_hosts

rm ~/.ssh/known_hosts
touch ~/.ssh/known_hosts
chmod 600 ~/.ssh/known_hosts
chmod 700 ~/.ssh

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
# check if the gsb-distro tag exists
# if not exit with an error

cd ${workspace_dir}/gsb-public-distro

ret_code=$(git ls-remote --tags $distro_url $tag | wc -l | tr -d ' ')
if [[ $ret_code != 1 ]]; then
    echo "gsb-public-distro tag = $tag not found"
    exit -1
else
    git pull 
fi

############################################
# check if the gsbpublic server exists
# if not exit with an error

cd ${workspace_dir}/gsbpublic

ret_code=$(git ls-remote $publicsite_url $server | wc -l | tr -d ' ')
if [[ $ret_code != 1 ]]; then
    echo "gsbpublic server = $server not found"
    exit -1
else
    git pull 
fi

############################################
# check if the gsb-distro directory exists
# if it doesn't clone it

cd $workspace_dir

if [ ! -d gsb-public-distro ]; then
    git clone -b master $distro_url
    if [ ! -d gsb-public-distro ]; then
       echo "gsb-public-distro cloned failed for branch = master"
       exit -1
    fi
    echo "gsb-public-distro directory created"
else 
    echo "gsb-public-distro directory exists"
fi

############################################
# checkout the gsb-distro tag
# 

cd ${workspace_dir}/gsb-public-distro
git checkout $tag

############################################
# check if the gsbpublic directory exists
# if it doesn't clone it

cd $workspace_dir

if [ ! -d gsbpublic ]; then
    git clone -b $server $publicsite_url 
    if [ ! -d gsbpublic ]; then
       echo "gsbpublic cloned failed for server = $server"
       exit -1
    fi    
    echo "gsbpublic directory created"
else
    echo "gsbpublic directory exists"
fi

############################################
# checkout the gsbpublic server
# 

cd ${workspace_dir}/gsbpublic
git checkout $server
git pull

############################################
# change to the gsbpublic directory
# remove the previous files from the docroot
# and then run the drush make

cd ${workspace_dir}/gsbpublic

rm -rf docroot

echo "start drush make"

# php /private/stanfordgsb/drush/drush.php vset date_default_timezone 'America/Los_Angeles' -y
php /private/stanfordgsb/drush/drush.php make ../gsb-public-distro/gsb-public-distro.make docroot

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
# the gsbpublic directory 

echo "begin - settings copy"

cp /private/stanfordgsb/settings_gsbpublic.php ${workspace_dir}/gsbpublic/docroot/sites/default/settings.php

echo "end - settings copy"

############################################
# create a gsb -> default symlink to 
# create a separate path for files

echo "begin - gsb symlink"

cd ${workspace_dir}/gsbpublic/docroot/sites
ln -s default gsb

echo "end - gsb symlink"

############################################
# create a favicon.ico -> profiles/gsb_public/themes/gsb_theme/favicon.ico 
# symlink to fix 404 errors.

echo "begin - favicon symlink"

cd ${workspace_dir}/gsbpublic/docroot
ln -s profiles/gsb_public/themes/gsb_theme/favicon.ico favicon.ico

echo "end - favicon symlink"

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

echo "build from cloudbees - project: gsbpublic  tag: $tag server: $server"

git add .
git add -f docroot/sites/default/settings.php
git commit -am "build from cloudbees - project: gsbpublic  tag: $tag server: $server"
git push origin $server

git tag $tag
git push origin --tags

echo "end - gsbpublic add/commit/push"

############################################
# run drush si on acquia site if 
# $rebuild is set to true
#

# Note: Moved this to a separate .sh called:
#   build_acquia_public_prod_post.sh

#ssh ${publicsite_ssh} "sh build/bin/acquia-build/build_prod.sh $server"

############################################
# end of build script 
#



