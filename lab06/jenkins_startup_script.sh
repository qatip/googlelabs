#!/bin/bash
set -e

sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y fontconfig openjdk-21-jre curl gnupg lsb-release unzip

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key | sudo tee /etc/apt/keyrings/jenkins-keyring.asc > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt-get update -y
echo "Installing Jenkins version $JENKINS_VERSION..."
sudo apt install -y jenkins=$JENKINS_VERSION
sudo apt-mark hold jenkins  # Prevent automatic updates

# Start and enable Jenkins
sudo systemctl start jenkins 
sudo systemctl enable jenkins 

# Allow Jenkins to run sudo commands
echo "Configuring sudo permissions for Jenkins..." 
echo "jenkins ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/jenkins
sudo chmod 440 /etc/sudoers.d/jenkins

