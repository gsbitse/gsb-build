#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR=$SCRIPT_DIR/build
DISTRO_DIR=$PROJECT_DIR/gsb-public-distro
PROFILE_DIR=$PROJECT_DIR/gsb_public


# Read the version number.
read -e -p "What is the version number that you are tagging?: " RELEASE_VERSION

# If nothing is specified then use the specified default.
if [ ! -n "RELEASE_VERSION" ]; then
  echo "A version number is required. Rerun this script when you have it."
  exit
fi

if [ ! -d "$PROJECT_DIR" ]; then
  echo "Making the build directory."
  mkdir "build"
fi

cd $PROJECT_DIR
if [ ! -d "gsb-public-distro" ]; then
  echo "Cloning the distro repository."
  git clone git@github.com:gsb-public/gsb-public-distro.git
fi

cd $DISTRO_DIR
git pull

if [ ! `git branch -r | grep release-$RELEASE_VERSION` ]; then
  echo "The release-$RELEASE_VERSION branch does not exist. Rerun the script when you are ready."
  exit
fi

# Double check the information is correct.
read -e -p "Are you sure you want to tag release-$RELEASE_VERSION? [y/N]: " THUNDERCATS_HO

# Check result
if [[ $THUNDERCATS_HO = "y" ]] || [[ $THUNDERCATS_HO = "Y" ]]; then
  cd $DISTRO_DIR
  git co release-$RELEASE_VERSION

  cd $PROJECT_DIR
  if [ ! -d "$PROFILE_DIR" ]; then
    git clone git@github.com:gsb-public/gsb_public.git
  fi

  # Get on the correct release version.
  cd $PROFILE_DIR
  git pull
  git co release-$RELEASE_VERSION

  # Loop through all the releases in the make and get their versions.
  git pull

  projects=()
  versions=()
  while read -r line ; do
    readline=`echo "$line" | grep "= release-"`

    if [ ! "$readline" ]; then
      continue;
    fi

    #Find project and version number.
    strip1='projects['
    newline=${line#$strip1}

    strip2='\]\[download\]\[branch\] = release-'
    projectInfo=(${newline//$strip2/ })

    projects+=(${projectInfo[0]})
    versions+=(${projectInfo[1]})
  done < $PROFILE_DIR/gsb_public.make

  for i in "${!projects[@]}"; do
    project=${projects[$i]}
    version=${versions[$i]}

    echo "Starting $project $version"

    echo "Rebase"
    # Rebase
    if [ ! -d "$PROJECT_DIR/$project" ]; then
      cd $PROJECT_DIR
      git clone git@github.com:gsb-public/$project.git
    fi

    cd $PROJECT_DIR/$project
    git co master
    git pull
    git co release-$version
    git pull
    git rebase master

    # Did rebase finish correctly?
    read -e -p "Did rebase finish correctly? [Y/n]: " REBASE

    # If no then exit.
    if [[ $REBASE = "N" || $REBASE = "n" ]]; then
      exit
    fi

    # Tag
    echo "Tag"
    git tag $version
    git push origin $version

    # Merge into Master
    echo "Merge into master"
    git co master
    git merge release-$version
    git push

    # Update gsb_public
    cd $PROFILE_DIR
    git pull
    echo Updating gsb_public make file
    sed -i '' "s/projects\[$project\]\[download\]\[branch\] = release-/projects\[$project\]\[download\]\[tag\] = /g" gsb_public.make
    git commit -am "Add $version tag of $project"
    git push

  done

  echo "Tag gsb_public"

  cd $PROFILE_DIR
  git rebase master

  # Did rebase finish correctly?
  read -e -p "Did rebase of gsb_public finish correctly? [Y/n]: " GSB_PUBLIC_REBASE

  # If no then exit.
  if [[ $GSB_PUBLIC_REBASE = "N" || $GSB_PUBLIC_REBASE = "n" ]]; then
    exit
  fi

  git tag $RELEASE_VERSION
  git push origin $RELEASE_VERSION
  git co master
  git merge release-$RELEASE_VERSION
  git push


  echo "Tag gsb-public-distro"
  cd $DISTRO_DIR
  git co release-$RELEASE_VERSION
  sed -i '' "s/projects\[gsb_public\]\[download\]\[branch\] = release-/projects\[gsb_public\]\[download\]\[tag\] = /g" gsb-public-distro.make
  git commit -am "Add $RELEASE_VERSION tag of gsb_public."
  git push
  git rebase master

  # Did rebase finish correctly?
  read -e -p "Did rebase of gsb-public-distro finish correctly? [Y/n]: " GSB_DISTRO_REBASE

  # If no then exit.
  if [[ $GSB_DISTRO_REBASE = "N" || $GSB_DISTRO_REBASE = "n" ]]; then
    exit
  fi

  git tag $RELEASE_VERSION
  git push origin $RELEASE_VERSION
  git co master
  git merge release-$RELEASE_VERSION
  git push
else
  echo "Please rerun the script when you are ready."
  exit
fi
