#!/usr/bin/env nu

def theme-value [mode dark_env light_env dark_default light_default] {
  if $mode == "light" {
    if ($light_env in $env) { ($env | get $light_env) } else { $light_default }
  } else {
    if ($dark_env in $env) { ($env | get $dark_env) } else { $dark_default }
  }
}

def detect-current-mode [] {
  let mode_file = ($env.HOME | path join ".cache" "zlx-theme-mode")
  if ($mode_file | path exists) {
    let persisted = (open --raw $mode_file | str trim | str downcase)
    if ($persisted == "dark" or $persisted == "light") {
      return $persisted
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

  "dark"
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

def main [] {
  let current = (detect-current-mode)
  let next = if $current == "dark" { "light" } else { "dark" }

  let cache_dir = ($env.HOME | path join ".cache")
  mkdir $cache_dir
  let mode_file = ($cache_dir | path join "zlx-theme-mode")
  $next | save -f $mode_file

  apply-st-runtime-theme $next

  print $"zlx theme toggled: ($current) -> ($next)"
}

