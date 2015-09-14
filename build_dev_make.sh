#!/bin/sh

############################################
# initialize the distro and acquia urls

project_name=gsb-public
distro_name=$project_name-distro
acquia_name=gsbpublic
distro_url=https://github.com/$project_name/$distro_name.git

############################################
# save the workspace root directory

workspace_dir=$PWD

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
# change to the acquia directory
# remove the previous files from the docroot
# and then run the drush make

cd ${workspace_dir}
cp -r /private/stanfordgsb/drush drush

project_folder="${workspace_dir}/${acquia_name}"
if [ ! -d $project_folder ];
then
  mkdir $project_folder
fi

cd $project_folder

rm -rf docroot

echo "start drush make"

php ../drush/drush.php make --working-copy ../$distro_name/$distro_name.make docroot

echo "end drush make"

############################################
# make sure the directory exists before
# continuing.

if [ ! -d docroot ]; then
  echo "The make failed"
  exit -1
fi

############################################
# create a gsb -> default symlink to 
# create a separate path for files

echo "begin - gsb symlink"

cd ${workspace_dir}/$acquia_name/docroot/sites
ln -s default gsb

echo "end - gsb symlink"

############################################
# add the changes up to acquia

echo "begin - $acquia_name add/commit/push"

cd ${workspace_dir}

tar_file=${acquia_name}.tar.gz
if [ -f tar_file ]; then
  rm -f $tar_file
fi
tar -czvf $tar_file $acquia_name

rm -rf gsb-build-dev-make-output
git clone git@github.com:gsbitse/gsb-build-dev-make-output.git
cd gsb-build-dev-make-output

mv ../${tar_file} .

git add ${tar_file}
git commit -am "build from cloudbees - project: $acquia_name  branch: $branch"
git push origin master

echo "end - $acquia_name add/commit/push"

############################################
# end of build script 
#
