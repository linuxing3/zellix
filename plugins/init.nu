use yazi.nu *
use nnn.nu *
use filer.nu *
use project.nu *
use ai.nu *
use makefile.nu *
use justfile.nu *
use home-manager.nu *
use terminal.nu *
use git.nu *
use tangle.nu *
use zk.nu *
use create-project.nu *
use logger-minimal.nu *

# Use this file to initialize any plugins and systems you need!
# 
# The main use of this should be to
# create files that would be used for config/data.
def main [] {
  init-logger
  init-yazi
  init-nnn
  init-filer
  init-project
  init-ai
  init-makefile
  init-justfile
  init-hm
  init-terminal
  init-git
  init-tangle
  init-zk
  init-create-project
}
