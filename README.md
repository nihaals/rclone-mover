# rclone-mover

## Usage

`rsync --partial --partial-dir=.rsync-partial rcloner/ upload-server:rcloner/ && ssh upload-server "~/rclone-mover/rclone-mover.nu start"`
