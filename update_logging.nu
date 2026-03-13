#!/usr/bin/env nu

# Script to update print statements to use logger

def update-file [file_path: string] {
  let content = (open $file_path)
  
  # Replace print statements with log calls
  let updated = ($content 
    | str replace --all 'print \(ansi red\)' 'log-error'
    | str replace --all 'print \(ansi yellow\)' 'log-warn'
    | str replace --all 'print \(ansi green\)' 'log-info'
    | str replace --all 'print \(ansi blue\)' 'log-info'
    | str replace --all 'print \(ansi cyan\)' 'log-info'
    | str replace --all 'print \(ansi dim\)' 'log-debug'
    | str replace --all 'print "' 'log-info "'
    | str replace --all 'log-info \(ansi reset\)"' 'log-info "'
    | str replace --all 'log-error \(ansi reset\)"' 'log-error "'
    | str replace --all 'log-warn \(ansi reset\)"' 'log-warn "'
    | str replace --all 'log-debug \(ansi reset\)"' 'log-debug "'
    | str replace --all '\(ansi reset\)' ''
    | str replace --all '\(ansi red_bold\)' ''
    | str replace --all '\(ansi yellow_bold\)' ''
    | str replace --all '\(ansi green_bold\)' ''
    | str replace --all '\(ansi blue_bold\)' ''
    | str replace --all '\(ansi cyan_bold\)' ''
  )
  
  # Add logger import if not present
  let has_logger_import = ($content | str contains "use logger.nu")
  let final_content = if not $has_logger_import {
    $"use logger.nu *\n\n($updated)"
  } else {
    $updated
  }
  
  $final_content | save $file_path
  print $"Updated: ($file_path)"
}

def main [] {
  let files = [
    "plugins/project.nu",
    "plugins/helpers.nu",
    "plugins/create-project.nu",
  ]
  
  for file in $files {
    update-file $file
  }
  
  print "✅ Logging updates completed"
}

main