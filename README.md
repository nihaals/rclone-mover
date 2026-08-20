# rclone-mover

## Usage

`rsync --partial --partial-dir=/.../.rsync-tmp --temp-dir=/.../.rsync-tmp rcloner/ upload-server:rcloner/ && ssh upload-server "~/rclone-mover/rclone-mover.nu start"`
