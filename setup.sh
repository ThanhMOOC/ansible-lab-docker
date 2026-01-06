#!/bin/bash

# Ansible-lab-Docker Setup Script (clean, build, run, deploy)
set -e

export ANSIBLE_HOST_KEY_CHECKING=False

echo "=========================================="
echo "Ansible-lab-Docker Setup Script"
echo "=========================================="

# Check Docker status
if ! docker info > /dev/null 2>&1; then
    echo "Error: Docker is not running. Please start Docker and try again."
    exit 1
fi

# Stop and remove containers
echo "Stopping and removing existing containers..."
docker compose down || true

# Remove old images (optional)
echo "Removing old images..."
docker rmi -f ansible-server:latest ansible-node1:latest ansible-node2:latest 2>/dev/null || true

# Build and start containers
echo "Building and starting containers..."
docker compose up -d --build

# Wait for containers to be ready
sleep 5

# Run Ansible playbook from ansible-server container
echo "Running Ansible playbook inside ansible-server container..."
docker compose exec ansible-server ansible-playbook /etc/ansible/install_web_stack.yaml -i /etc/ansible/hosts.ini

echo "Setup completed! All containers and configs are up to date."
