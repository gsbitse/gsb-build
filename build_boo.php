<?php
exec('git ls-remote -h https://github.com/gsbitse/gsb-distro.git', $output);
print('branches='.preg_replace('/[a-z0-9]*\trefs\/heads\//','',implode(',', $output)));
?>
