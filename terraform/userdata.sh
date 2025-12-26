#!/bin/bash
# Simple userdata: install Git + Docker (auto-detect OS)

set -euxo pipefail

# Log everything
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "===== USERDATA START ====="
cat /etc/os-release || true

# -----------------------------
# Ubuntu / Debian
# -----------------------------
if command -v apt-get >/dev/null 2>&1; then
  echo "Detected apt-based system"
  apt-get update -y
  apt-get install -y git docker.io
  systemctl enable docker
  systemctl start docker

# -----------------------------
# Amazon Linux 2023 (dnf)
# -----------------------------
elif command -v dnf >/dev/null 2>&1; then
  echo "Detected dnf-based system (Amazon Linux 2023)"
  dnf update -y
  dnf install -y git moby-engine docker-cli
  systemctl daemon-reexec
  systemctl enable docker
  systemctl start docker

# -----------------------------
# Amazon Linux 2 (yum)
# -----------------------------
elif command -v yum >/dev/null 2>&1; then
  echo "Detected yum-based system (Amazon Linux 2)"
  yum update -y
  yum install -y git
  amazon-linux-extras enable docker
  yum install -y docker
  systemctl daemon-reexec
  systemctl enable docker
  systemctl start docker
fi

# -----------------------------
# Permissions (optional but recommended)
# -----------------------------
if id ec2-user >/dev/null 2>&1; then
  usermod -aG docker ec2-user
fi

# -----------------------------
# Verification
# -----------------------------
echo "Git:"
git --version || true

echo "Docker:"
docker --version || true

echo "Docker service:"
systemctl status docker --no-pager || true

echo "===== USERDATA COMPLETE ====="
