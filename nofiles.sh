#! /bin/bash

# The default open files limit on Linux/systemd is pretty low, 1024 (soft) and
# 4096 (hard). Set it to a large value.

set -e -u -o pipefail

mkdir -p /etc/systemd/system.conf.d

cat > /etc/systemd/system.conf.d/nofile.conf << END
[Manager]
# Allow the system to open more than a few thousand files at a time.
DefaultLimitNOFILE=65536
END
