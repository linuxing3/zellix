#!/usr/bin/env nu

use zlx-theme-common.nu *

def main [] {
  let current = (detect-theme-mode)
  let next = if $current == "dark" { "light" } else { "dark" }

  let cache_dir = ($env.HOME | path join ".cache")
  mkdir $cache_dir
  $next | save -f ($cache_dir | path join "zlx-theme-mode")

  apply-st-runtime-theme $next

  print $"zlx theme toggled: ($current) -> ($next)"
}
