#!/bin/bash
set -euxo pipefail

# Log everything
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "===== USERDATA START ====="

# Update system
dnf update -y

# Install Git
dnf install -y git

# Install Docker (CORRECT for AL2023)
dnf install -y moby-engine docker-cli

# Enable & start Docker
systemctl daemon-reexec
systemctl enable docker
systemctl start docker

# Add ec2-user to docker group
usermod -aG docker ec2-user

# Verify
echo "Docker binary:"
which docker || echo "docker not in PATH"

echo "Docker version:"
docker --version || true

echo "Docker service:"
systemctl status docker --no-pager || true

echo "===== USERDATA COMPLETE ====="
