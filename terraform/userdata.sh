#!/bin/bash
set -euxo pipefail

# Log everything for debugging
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "===== USERDATA START ====="

echo "=== OS INFO ==="
cat /etc/os-release

# -------------------------------
# System update
# -------------------------------
echo "=== Updating system ==="
dnf update -y

# -------------------------------
# Install Git
# -------------------------------
echo "=== Installing Git ==="
dnf install -y git

# -------------------------------
# Install Docker
# -------------------------------
echo "=== Installing Docker ==="
dnf install -y docker

systemctl enable docker
systemctl start docker

# Allow ec2-user to run Docker
usermod -aG docker ec2-user

# -------------------------------
# Verification
# -------------------------------
echo "=== VERIFY INSTALLATIONS ==="

echo "Git version:"
git --version

echo "Docker version:"
docker --version

echo "Docker service status:"
systemctl status docker --no-pager

echo "===== USERDATA COMPLETE ====="
