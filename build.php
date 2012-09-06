#!/usr/bin/env php
<?php

shell_exec('cd ..');

if (file_exists("gsb-build")) {
  echo "gsb-build directory exists"; 
}

echo "done";
