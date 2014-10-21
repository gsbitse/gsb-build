<?php
exec('git ls-remote -h https://github.com/gsb-public/gsb-public-distro.git', $output);

$versions = array();
foreach ($output as $branch) {
  if (stristr($branch, 'release-')) {
    $branch_array = explode('release-', $branch);
    $versions[] = $branch_array[1];
  }
}

usort($versions, 'version_compare');
$versions = array_slice($versions, -5);
$versions = array_reverse($versions);
foreach ($versions as $index => $version) {
  $versions[$index] = 'release-' . $version;
}
$branches_out = 'branches=' . implode(',', $versions);
$file_out = "branches-latest.txt";
$fh = fopen($file_out, 'w');
fwrite($fh, $branches_out);
fclose($fh);
?>
