#!/usr/bin/env nix
#!nix shell nixpkgs#nushell nixpkgs#rclone nixpkgs#tmux --command nu

const session_name = "rclone-mover"
const source = "~/rcloner/" | path expand
const destination = "me-drive:Dropbox/"
const self_path = (path self)
const queue_file = "/tmp/rclone-mover.queue"

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
        touch $queue_file
        print "Upload in progress, queued another run after it finishes"
      } else {
        create_session $"nu \"($self_path)\" upload"
        print $"Started tmux session '($session_name)'"
        print $"Moving ($source) -> ($destination)"
      }
    }
    "upload" => {
      loop {
        if ($queue_file | path exists) {
          rm $queue_file
          print "Cleared queued upload"
        }
        rclone move --progress --transfers 2 --order-by size,asc $source $destination
        if not ($queue_file | path exists) {
          break
        }
        print "Queued upload detected, running again..."
      }
      tmux set-option -t $session_name remain-on-exit off
    }
    _ => {
      error make { msg: $"Unknown command: ($command)" }
    }
  }
}
