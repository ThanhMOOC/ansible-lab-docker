#!/bin/bash

# Setup script for Ansible-lab-Docker: build, run containers, and execute Ansible playbook
set -e

echo "=========================================="
echo "Ansible-lab-Docker Setup Script"
echo "=========================================="

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "Error: Docker is not running. Please start Docker and try again."
    exit 1
fi

# Stop and remove existing containers if they exist
echo "Stopping and removing existing containers..."
docker compose down || true

# Remove old images (optional, for clean build)
echo "Removing old images..."
docker rmi -f ansible-server:latest ansible-node1:latest ansible-node2:latest 2>/dev/null || true

# Build and start containers using docker-compose
echo "Building and starting containers..."
docker compose up -d --build

# Wait for containers to be ready
echo "Waiting for containers to be ready..."
sleep 5

# Run Ansible playbook from host (using docker connection)
echo "Running Ansible playbook..."
ansible-playbook -i shared_folder/hosts.ini shared_folder/install_web_stack.yaml

echo "\nSetup completed!"
