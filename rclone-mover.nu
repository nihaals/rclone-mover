#!/usr/bin/env nix
#!nix shell nixpkgs#nushell nixpkgs#rclone nixpkgs#tmux --command nu

const session_name = "rclone-mover"
const source = "~/rcloner/" | path expand
const destination = "me-drive:Dropbox/"
const self_path = (path self)

def session_exists [] {
  (tmux has-session -t $session_name | complete).exit_code == 0
}

def create_session [command: string] {
  tmux new-session -d -s $session_name $command
  tmux set-option -t $session_name remain-on-exit on
}

def main [command: string] {
  match $command {
    "start" => {
      if (session_exists) {
        error make { msg: $"tmux session '($session_name)' is already running" }
      }

      create_session $"nu \"($self_path)\" upload"

      print $"Started tmux session '($session_name)'"
      print $"Moving ($source) -> ($destination)"
    }
    "upload" => {
      rclone move --progress $source $destination
    }
    _ => {
      error make { msg: $"Unknown command: ($command)" }
    }
  }
}
