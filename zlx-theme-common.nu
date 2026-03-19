#!/usr/bin/env nu

# Shared theme utilities for zlx-theme*.nu scripts.

export def theme-value [mode: string, dark_env: string, light_env: string, dark_default: string, light_default: string] {
  if $mode == "light" {
    $env | get -o $light_env | default $light_default
  } else {
    $env | get -o $dark_env | default $dark_default
  }
}

export def apply-st-runtime-theme [mode: string] {
  let fg = (theme-value $mode "ZLX_ST_FG_DARK" "ZLX_ST_FG_LIGHT" "#ebdbb2" "#3c3836")
  let bg = (theme-value $mode "ZLX_ST_BG_DARK" "ZLX_ST_BG_LIGHT" "#1d2021" "#fbf1c7")
  let cursor = (theme-value $mode "ZLX_ST_CURSOR_DARK" "ZLX_ST_CURSOR_LIGHT" "#fabd2f" "#076678")

  let esc = "\u{1b}"
  let bel = "\u{7}"
  print -n $"($esc)]10;($fg)($bel)"
  print -n $"($esc)]11;($bg)($bel)"
  print -n $"($esc)]12;($cursor)($bel)"
}

# Detect theme mode from cache file → polarity.txt → fallback.
export def detect-theme-mode [fallback?: string] {
  let fallback = ($fallback | default "dark")

  let mode_file = ($env.HOME | path join ".cache" "zlx-theme-mode")
  if ($mode_file | path exists) {
    let persisted = (open --raw $mode_file | str trim | str downcase)
    if $persisted in ["dark" "light"] { return $persisted }
  }

  let current_theme_file = ($env.HOME | path join ".currenttheme")
  if ($current_theme_file | path exists) {
    let current_theme = (open --raw $current_theme_file | str trim)
    if ($current_theme | is-not-empty) {
      let polarity_file = ($env.HOME | path join ".config" "home-manager" "themes" $current_theme "polarity.txt")
      if ($polarity_file | path exists) {
        let polarity = (open --raw $polarity_file | str trim | str downcase)
        if $polarity in ["dark" "light"] { return $polarity }
      }
    }
  }

  $fallback
}
