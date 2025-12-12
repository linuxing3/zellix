export def init-git [] {}

def main [ filepath: string ] {
  let choice = ([ glow lowdown bat ] | input list )
  let command = match $choice {
    "glow" => $"glow ($filepath)",
    "bat" => $"bat ($filepath)",
    "lowdown" => $"lowdown ($filepath) | save -f /tmp/lowdown_preview.html; w3m /tmp/lowdown_preview.html"
    _ => $"less ($filepath)",
  }
  nu -c $command
}
