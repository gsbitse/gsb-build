<?php
exec('git ls-remote -h https://github.com/gsbitse/gsb-distro.git', $output);
$branches_out = 'branches=' . preg_replace('/[a-z0-9]*\trefs\/heads\//','',implode(',', $output));
$myFile = "zz.txt";
$fh = fopen($myFile, 'w');
fwrite($fh, $branches_out);
fclose($fh);
?>
