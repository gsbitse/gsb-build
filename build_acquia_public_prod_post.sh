#!/bin/sh

############################################
# initialize the ssh path

publicsite_dev_ssh="gsbpublic@staging-1530.prod.hosting.acquia.com"
publicsite_dev2_ssh="gsbpublic@staging-1530.prod.hosting.acquia.com"
publicsite_stage_ssh="gsbpublic@ded-2036.prod.hosting.acquia.com"
publicsite_stage2_ssh="gsbpublic@ded-2036.prod.hosting.acquia.com"
publicsite_sandbox_ssh="gsbpublic@staging-1530.prod.hosting.acquia.com"
publicsite_loadtest_ssh="gsbpublic@ded-1505.prod.hosting.acquia.com"
publicsite_prod_ssh="gsbpublic@ded-1528.prod.hosting.acquia.com"

server="prod"

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
# run drush si on acquia site if 
# $rebuild is set to true
#

ssh ${publicsite_ssh} "sh build/bin/acquia-build/build_prod.sh $server"

############################################
# end of build script 
#
