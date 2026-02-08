export def init-justfile [] {}


def select-action [ ] {
  let action = just -l -d . -f justfile | each {|l| $l | split row "\n"} | flatten | compact --empty | each { |l| $"just ($l)" } | input list
  $"($action)"
}

def main [] {
  let action: string = select-action
  nu -c $action
}
