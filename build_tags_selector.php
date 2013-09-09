<?php
exec('git ls-remote --tags https://github.com/gsbitse/gsb-distro.git', $output);
$tags_out = 'tags=' . preg_replace('/[a-z0-9]*\trefs\/tags\//','',implode(',', $output));
$file_out = "tags.txt";
$fh = fopen($file_out, 'w');
fwrite($fh, $tags_out);
fclose($fh);
?>
