#!/bin/bash
set -e

#entrypoint-node.sh 

echo "=== Removing old potentially corrupted keys ==="
rm -f /etc/ssh/ssh_host_*

echo "=== Generating fresh SSH host keys ==="
ssh-keygen -A

echo "=== Verifying generated keys ==="
ls -la /etc/ssh/ssh_host_*

echo "=== Testing sshd configuration ==="
/usr/sbin/sshd -t


echo "=== Starting SSH daemon ==="
exec /usr/sbin/sshd -D -e

#chmod +x entrypoint.sh
