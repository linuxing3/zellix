try { nu ($env.ZELLIX_MOD + "/init.nu") }

# Open helix at the given filepath.
let path = match $env.ZELLIX_OPEN {
  null => ""
  _ => $env.ZELLIX_OPEN
}

hx $path

# Run exit code for the selected modules
# This is a try block because exit.nu shouldn't be required
try { nu ($env.ZELLIX_MOD + "/exit.nu") }

# Kill the session, closing other panes as soon as helix closes
zellij kill-session $env.ZELLIX_SESSION
