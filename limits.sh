#! /bin/bash

# The default open files limit on Linux/systemd is pretty low, 1024 (soft) and
# 4096 (hard). So is systemd's default TasksMax limit. Raise both of them.

set -e -u -o pipefail

mkdir -p /etc/systemd/system.conf.d

cat > /etc/systemd/system.conf.d/limits.conf << END
[Manager]
# Allow the system to open more than a few thousand files at a time.
DefaultLimitNOFILE=65536
# Allow more than 512 threads.
DefaultTasksMax=65536
END
