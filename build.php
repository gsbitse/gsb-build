#!/usr/bin/env php
<?php

shell_exec('cd ..');

if (file_exists("gsb-build")) {
  echo "gsb-build directory exists\n";
}

if (file_exists("gsb-public")) {
  echo "gsb-public directory exists\n";
} else {
  echo "cloning gsb-public\n";
  shell_exec('git clone https://github.com/gsbitse/gsb-public.git');
}

if (file_exists("gsb-distro")) {
  echo "gsb-distro directory exists\n";
} else {
  echo "cloning gsb-distro\n";
  shell_exec('git clone https://github.com/gsbitse/gsb-distro.git');
}

if (file_exists("revamp")) {
  echo "revamp directory exists\n";
} else {
  echo "cloning revamp\n";
  shell_exec('git clone revamp@svn-634.devcloud.hosting.acquia.com:revamp.git');
}

if (file_exists("drush")) {
  echo "drush directory exists\n";
} else {
  echo "cloning drush\n";
  shell_exec('git clone http://git.drupal.org/project/drush.git');
}

shell_exec('cd revamp');

shell_exec('rm -r docroot');

shell_exec('php ../drush/drush.php make ../gsb-distro/gsb-public-distro.make docroot');

shell_exec('git add .');

shell_exec('git commit -am "build from cloudbees"');

shell_exec('git push');

echo "done\n";

