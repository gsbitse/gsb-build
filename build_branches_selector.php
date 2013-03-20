<?php
exec('git ls-remote -h https://github.com/gsbitse/gsb-distro.git', $output);
$branches_out = 'branches=' . preg_replace('/[a-z0-9]*\trefs\/heads\//','',implode(',', $output));
$file_out = "branches.txt";
$fh = fopen($file_out, 'w');
fwrite($fh, $branches_out);
fclose($fh);
?>
