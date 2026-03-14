#!/usr/bin/env nu

def detect-theme-mode [] {
  if ("ZLX_THEME_MODE" in $env) {
    let mode = ($env.ZLX_THEME_MODE | str downcase | str trim)
    if ($mode == "dark" or $mode == "light") {
      return $mode
    }
  }

  let current_theme_file = ($env.HOME | path join ".currenttheme")
  if ($current_theme_file | path exists) {
    let current_theme = (open --raw $current_theme_file | str trim)
    if ($current_theme != "") {
      let polarity_file = ($env.HOME | path join ".config" "home-manager" "themes" $current_theme "polarity.txt")
      if ($polarity_file | path exists) {
        let polarity = (open --raw $polarity_file | str trim | str downcase)
        if ($polarity == "dark" or $polarity == "light") {
          return $polarity
        }
      }
    }
  }

  let hour = (date now | format date "%H" | into int)
  if ($hour >= 7 and $hour < 18) { "light" } else { "dark" }
}

def theme-value [mode dark_env light_env dark_default light_default] {
  if $mode == "light" {
    if ($light_env in $env) { ($env | get $light_env) } else { $light_default }
  } else {
    if ($dark_env in $env) { ($env | get $dark_env) } else { $dark_default }
  }
}

def apply-st-runtime-theme [mode] {
  let fg = (theme-value $mode "ZLX_ST_FG_DARK" "ZLX_ST_FG_LIGHT" "#ebdbb2" "#3c3836")
  let bg = (theme-value $mode "ZLX_ST_BG_DARK" "ZLX_ST_BG_LIGHT" "#1d2021" "#fbf1c7")
  let cursor = (theme-value $mode "ZLX_ST_CURSOR_DARK" "ZLX_ST_CURSOR_LIGHT" "#fabd2f" "#076678")

  let esc = "\u{1b}"
  let bel = "\u{7}"
  print -n $"($esc)]10;($fg)($bel)"
  print -n $"($esc)]11;($bg)($bel)"
  print -n $"($esc)]12;($cursor)($bel)"
}

def main [
  mode?: string # dark | light | auto
] {
  let selected = match ($mode | default "auto" | str downcase | str trim) {
    "dark" => "dark"
    "light" => "light"
    "auto" => (detect-theme-mode)
    _ => (detect-theme-mode)
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
  print $"  let-env ZLX_THEME_MODE = \"($selected)\""
  print $"  let-env ZLX_HELIX_THEME_($selected | str upcase) = \"($helix_theme)\""
  print $"  let-env ZLX_ZELLIJ_THEME_($selected | str upcase) = \"($zellij_theme)\""
}
