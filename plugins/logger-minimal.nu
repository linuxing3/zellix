# Minimal logger for testing

export def init-logger [] {
  print "Logger initialized"
}

export def log-info [message: string] {
  print $"INFO: ($message)"
}

export def log-error [message: string] {
  print $"ERROR: ($message)"
}

export def log-warn [message: string] {
  print $"WARN: ($message)"
}

export def log-debug [message: string] {
  print $"DEBUG: ($message)"
}