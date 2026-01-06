#!/bin/bash
set -e

# entrypoint-server.sh  #chmod +x entrypoint.sh
echo "=== Removing old potentially corrupted keys ==="
rm -f /etc/ssh/ssh_host_*

echo "=== Generating fresh SSH host keys ==="
ssh-keygen -A

echo "=== Verifying generated keys ==="
ls -la /etc/ssh/ssh_host_*

echo "=== Testing sshd configuration ==="
/usr/sbin/sshd -t
 

#ssh-keygen -t ed25519 
# "=== Generating SSH client key (non-interactive) ==="
mkdir -p /root/.ssh
chmod 700 /root/.ssh

ssh-keygen -t ed25519 -f /root/.ssh/id_ed25519 -N "" -q

#echo "=== Starting SSH daemon in background ==="
#/usr/sbin/sshd

# Ajouter la clé des nodes dans les known_hosts  de ansible-server 
echo "=== Adding node1 to known_hosts ==="
ssh-keyscan -H node1 >> ~/.ssh/known_hosts 2>/dev/null
echo "===  known_hosts de ansible-server ==="
cat ~/.ssh/known_hosts

echo "=== Copying SSH key to node1 (with auto-accept and password) ==="
sshpass -p '1234' ssh-copy-id -o StrictHostKeyChecking=no -i /root/.ssh/id_ed25519.pub root@node1 || echo "Failed to copy key to node1"


echo "=== Adding node2 to known_hosts ===" 
ssh-keyscan -H node2 >> ~/.ssh/known_hosts 2>/dev/null 
echo "=== Copying SSH key to node2 (with auto-accept and password) ==="
sshpass -p '1234' ssh-copy-id -o StrictHostKeyChecking=no -i /root/.ssh/id_ed25519.pub root@node2 || echo "Failed to copy key to node2"



echo "=== Testing SSH connection to node1 ==="
ssh -o StrictHostKeyChecking=no root@node1 'echo "Connected to $(hostname)"' || echo "SSH test to node1 failed"

echo "=== Testing SSH connection to node2 ==="
ssh -o StrictHostKeyChecking=no root@node2 'echo "Connected to $(hostname)"' || echo "SSH test to node2 failed"


#echo "=== Starting SSH daemon ==="
#exec /usr/sbin/sshd -D -e

 echo "=== Starting SSH daemon in background ==="
/usr/sbin/sshd -D -e &



echo "=== SSH setup complete ==="
echo "=== Keeping container alive ==="
tail -f /dev/null