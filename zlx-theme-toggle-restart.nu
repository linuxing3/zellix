#!/usr/bin/env nu

def main [] {
  let session = (if ("ZELLIX_SESSION" in $env) { $env.ZELLIX_SESSION } else { "" })
  if ($session | str trim) == "" {
    print "zlx theme: ZELLIX_SESSION not set, cannot restart automatically."
    exit 1
  }

  # Toggle persisted theme mode first.
  ^nu /home/Designers/.config/zellix/zlx-theme-toggle.nu

  # Ask outer run.nu process to relaunch this session after zellij exits.
  let restart_flag = $"/tmp/zellix/restart-($session).flag"
  "" | save -f $restart_flag
  print $"zlx theme: restarting session '($session)' to fully apply zellij/helix theme..."
  ^zellij kill-session $session
}
