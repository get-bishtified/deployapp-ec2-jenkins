#!/bin/bash
set -euxo pipefail

# Log everything
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "===== USERDATA START ====="

# Update system
dnf update -y

# Install Git
dnf install -y git

# Install Docker
dnf install -y docker

# Enable & start Docker
systemctl daemon-reexec
systemctl enable docker
systemctl start docker

# Add ec2-user to docker group
usermod -aG docker ec2-user

# Verify
echo "Git:"
git --version

echo "Docker:"
docker --version || echo "Docker command not available yet"

echo "===== USERDATA COMPLETE ====="
