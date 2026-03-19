#!/usr/bin/env nu

use zlx-theme-common.nu *

def main [
  mode?: string # dark | light | auto
] {
  let selected = match ($mode | default "auto" | str downcase | str trim) {
    "dark" => "dark"
    "light" => "light"
    _ => {
      let env_mode = ($env.ZLX_THEME_MODE? | default "" | str downcase | str trim)
      if $env_mode in ["dark" "light"] {
        $env_mode
      } else {
        let hour = (date now | format date "%H" | into int)
        if ($hour >= 7 and $hour < 18) { "light" } else { "dark" }
      }
    }
  }

  let helix_theme = (theme-value $selected "ZLX_HELIX_THEME_DARK" "ZLX_HELIX_THEME_LIGHT" "gruvbox_dark_hard" "gruvbox_light_hard")
  let zellij_theme = (theme-value $selected "ZLX_ZELLIJ_THEME_DARK" "ZLX_ZELLIJ_THEME_LIGHT" "catppuccin-mocha" "gruvbox-light-hard")

  apply-st-runtime-theme $selected

  print ""
  print $"Applied st runtime colors for mode: ($selected)"
  print $"Helix theme target: ($helix_theme)"
  print $"Zellij theme target: ($zellij_theme)"
  print ""
  print "Apply for next zlx launch in this shell:"
  print $"  $env.ZLX_THEME_MODE = \"($selected)\""
  print $"  $env.ZLX_HELIX_THEME_($selected | str upcase) = \"($helix_theme)\""
  print $"  $env.ZLX_ZELLIJ_THEME_($selected | str upcase) = \"($zellij_theme)\""
}
