export def init-justfile [] {}

def main [] {
  let action = (
    just -l -d . -f justfile
    | lines
    | compact --empty
    | each {|l| $"just ($l)" }
    | input list
  )
  nu -c $action
}
