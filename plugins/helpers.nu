
export def send-to-helix [ command: string, cd?: string ] {
  
  zellij action toggle-floating-panes # Select Helix In The System
  zellij action write 27 # Exit To Normal Mode

  zellij action write-chars $command # Write actual Command
  zellij action write 13 # Press Enter to run the command

  if $cd != "" {
    zellij action write-chars $":cd ($cd)" # Change to last file directory
    zellij action write 13 # Press Enter to run the command
  }
} 
