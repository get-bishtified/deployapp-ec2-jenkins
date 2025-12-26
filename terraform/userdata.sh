#!/bin/bash
set -euxo pipefail

# Log everything
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "===== USERDATA START ====="
cat /etc/os-release

# Detect package manager (supports dnf or yum)
if command -v dnf >/dev/null 2>&1; then
  PKG=dnf
else
  PKG=yum
fi

# Update system
$PKG update -y

# Install Git and Docker
$PKG install -y git docker

# Enable & start Docker
systemctl daemon-reexec
systemctl enable docker
systemctl start docker

# Allow ec2-user to run Docker
usermod -aG docker ec2-user

# Verify
echo "Docker binary:"
which docker || true

echo "Docker version:"
docker --version || true

echo "Docker service:"
systemctl status docker --no-pager || true

echo "===== USERDATA COMPLETE ====="
