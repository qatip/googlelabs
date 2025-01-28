#!/bin/bash
# Update and upgrade the system
sudo apt update -y && sudo apt upgrade -y

# Install required dependencies
sudo apt install -y openjdk-17-jdk unzip curl

# Add Jenkins repository and key
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# Install Jenkins
sudo apt update -y
sudo apt install -y jenkins

# Start and enable Jenkins service
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Grant Jenkins sudo permissions without password
echo "jenkins ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/jenkins
sudo chmod 440 /etc/sudoers.d/jenkins

# Wait for Jenkins to initialize
echo "Waiting for Jenkins to initialize..."
sleep 30

# Define log file location
LOG_FILE="/var/log/jenkins_setup.log"

# Ensure log file exists
sudo touch $LOG_FILE
sudo chmod 644 $LOG_FILE

# Output the Jenkins initial admin password to a file and log
if [[ -f /var/lib/jenkins/secrets/initialAdminPassword ]]; then
    sudo cat /var/lib/jenkins/secrets/initialAdminPassword | sudo tee /home/ubuntu/jenkins_admin_password.txt >> $LOG_FILE
    echo "Jenkins Initial Admin Password saved at /home/ubuntu/jenkins_admin_password.txt" | sudo tee -a $LOG_FILE
else
    echo "ERROR: Jenkins initial admin password file not found. Check Jenkins service logs." | sudo tee -a $LOG_FILE
    sudo systemctl status jenkins >> $LOG_FILE 2>&1
fi

