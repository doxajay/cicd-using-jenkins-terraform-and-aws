#!/bin/bash
set -e

# Update system
sudo yum update -y

# Install Java 17
sudo amazon-linux-extras install java-openjdk17 -y

# Add Jenkins repository and key
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

# Install Jenkins and dependencies
sudo yum install jenkins git docker -y

# Enable and start Jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Enable and start Docker
sudo systemctl enable docker
sudo systemctl start docker

# Add Jenkins user to Docker group
sudo usermod -aG docker jenkins
sudo chmod 666 /var/run/docker.sock

# Firewall open for Jenkins
sudo firewall-cmd --permanent --add-port=8080/tcp || true
sudo firewall-cmd --reload || true

echo "✅ Jenkins installed and running on port 8080"
