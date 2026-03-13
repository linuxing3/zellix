# Zellix Logger Utility
# Provides structured logging and error handling

export def init-logger [] {
  # Initialize logger with default settings
  let-env ZELLIX_LOG_LEVEL = $env.ZELLIX_LOG_LEVEL? | default "info"
  let-env ZELLIX_LOG_FILE = $env.ZELLIX_LOG_FILE? | default ($env.ZELLIX_TMP? | default "/tmp/zellix") + "/zellix.log"
  
  # Create log directory if it doesn't exist
  let log_dir = ($env.ZELLIX_LOG_FILE | path dirname)
  if not ($log_dir | path exists) {
    mkdir $log_dir
  }
  
  print $"(ansi dim)Logger initialized (level: ($env.ZELLIX_LOG_LEVEL), file: ($env.ZELLIX_LOG_FILE))(ansi reset)"
}

# Log levels
def log-levels [] {
  {
    debug: 0,
    info: 1,
    warn: 2,
    error: 3,
    fatal: 4
  }
}

# Check if should log at given level
def should-log [level: string] {
  let current_level = ($env.ZELLIX_LOG_LEVEL | str downcase)
  let levels = (log-levels)
  
  let current_num = $levels | get --optional $current_level | default 1
  let requested_num = $levels | get --optional $level | default 1
  
  $requested_num >= $current_num
}

# Format log message
def format-log [level: string, message: string, context?: record] {
  let timestamp = (date now | format date "%Y-%m-%d %H:%M:%S%.3f")
  let level_str = ($level | str upcase | fill -a r -w 5)
  let session = $env.ZELLIX_SESSION? | default "unknown"
  
  let context_str = if ($context? != null) {
    let ctx_parts = ($context | each {|key, value| $\"($key)=($value)\"} | str join " ")
    if ($ctx_parts | is-empty) { "" } else { $\" [$ctx_parts]\" }
  } else {
    ""
  }
  
  $\"($timestamp) [$session] $level_str: ($message)($context_str)\"
}

# Write log to file
def write-log [log_entry: string] {
  try {
    $log_entry | save --append $env.ZELLIX_LOG_FILE
  } catch {|err|
    # Fallback to stderr if file logging fails
    print $"(ansi red)Log write failed: ($err)(ansi reset)"
    print $log_entry
  }
}

# Log functions
export def log-debug [message: string, context?: record] {
  if (should-log "debug") {
    let entry = (format-log "debug" $message $context)
    write-log $entry
    print $"(ansi dim)DEBUG: ($message)(ansi reset)"
  }
}

export def log-info [message: string, context?: record] {
  if (should-log "info") {
    let entry = (format-log "info" $message $context)
    write-log $entry
    print $"(ansi blue)INFO: ($message)(ansi reset)"
  }
}

export def log-warn [message: string, context?: record] {
  if (should-log "warn") {
    let entry = (format-log "warn" $message $context)
    write-log $entry
    print $"(ansi yellow)WARN: ($message)(ansi reset)"
  }
}

export def log-error [message: string, context?: record] {
  if (should-log "error") {
    let entry = (format-log "error" $message $context)
    write-log $entry
    print $"(ansi red)ERROR: ($message)(ansi reset)"
  }
}

export def log-fatal [message: string, context?: record] {
  let entry = (format-log "fatal" $message $context)
  write-log $entry
  print $"(ansi red_bold)FATAL: ($message)(ansi reset)"
  exit 1
}

# Error handling wrapper
export def try-with-log [command: closure, error_message: string] {
  try {
    do $command
  } catch {|err|
    log-error $error_message { error: $err }
    null
  }
}

# Measure execution time
export def measure-time [name: string, command: closure] {
  let start_time = (date now)
  
  log-debug $"Starting ($name)"
  let result = (do $command)
  let end_time = (date now)
  let duration = ($end_time - $start_time)
  
  log-debug $"Completed ($name)" { duration: $duration }
  $result
}

# Get log file contents
export def get-logs [lines?: int] {
  let line_count = $lines? | default 100
  
  if ($env.ZELLIX_LOG_FILE | path exists) {
    try {
      open $env.ZELLIX_LOG_FILE | lines | last $line_count
    } catch {|err|
      log-error "Failed to read log file" { error: $err }
      []
    }
  } else {
    log-warn "Log file does not exist"
    []
  }
}

# Clear logs
export def clear-logs [] {
  if ($env.ZELLIX_LOG_FILE | path exists) {
    try {
      rm $env.ZELLIX_LOG_FILE
      log-info "Logs cleared"
      true
    } catch {|err|
      log-error "Failed to clear logs" { error: $err }
      false
    }
  } else {
    true
  }
}