#!/bin/bash
set -euxo pipefail

exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

dnf update -y
dnf install -y git moby-engine docker-cli

systemctl daemon-reexec
systemctl enable docker
systemctl start docker

usermod -aG docker ec2-user
