sudo dnf update -y
sudo dnf install -y moby-engine docker-cli git
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker ec2-user
exit
