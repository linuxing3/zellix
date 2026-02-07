export def init-justfile [] {}


def select-action [ ] {
  let action = just --list --working-directory . --justfile justfile | each {|l| $l | split row "\n"} | flatten | compact --empty | skip 1 | each { |l| $"just ($l)" } | input list
  $"($action)"
}

def main [] {
  let action: string = select-action
  nu -c $action
}
