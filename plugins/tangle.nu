export def init-tangle [] {}

def main [filepath: string] {
  if ($filepath | is-not-empty) {
    doom +org tangle --all $filepath
  }
}
