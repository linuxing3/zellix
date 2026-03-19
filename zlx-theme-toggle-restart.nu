#!/usr/bin/env nu

def main [] {
  let session = ($env.ZELLIX_SESSION? | default "")
  if ($session | is-empty) {
    print "zlx theme: ZELLIX_SESSION not set, cannot restart automatically."
    exit 1
  }

  ^nu /home/Designers/.config/zellix/zlx-theme-toggle.nu

  "" | save -f $"/tmp/zellix/restart-($session).flag"
  print $"zlx theme: restarting session '($session)' to fully apply zellij/helix theme..."
  ^zellij kill-session $session
}
