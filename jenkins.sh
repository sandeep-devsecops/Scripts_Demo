#!/bin/bash

set -e

echo "======================================"
echo " Installing Jenkins on Ubuntu"
echo "======================================"

# 1. Update system
echo "[1/6] Updating packages..."
sudo apt update
sudo apt upgrade -y

# 2. Install Java 21
echo "[2/6] Installing Java 21..."
sudo apt install -y fontconfig openjdk-21-jre

# Check Java
echo "Java version:"
java -version

# 3. Add Jenkins repository key
echo "[3/6] Adding Jenkins repository key..."

sudo mkdir -p /etc/apt/keyrings

sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key

# 4. Add Jenkins LTS repository
echo "[4/6] Adding Jenkins LTS repository..."

echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" \
| sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# 5. Install Jenkins
echo "[5/6] Installing Jenkins..."

sudo apt update
sudo apt install -y jenkins

# 6. Enable and start Jenkins
echo "[6/6] Starting Jenkins..."

sudo systemctl enable jenkins
sudo systemctl start jenkins

echo ""
echo "======================================"
echo " Jenkins Installation Complete!"
echo "======================================"

echo ""
echo "Jenkins Status:"
sudo systemctl --no-pager status jenkins

echo ""
echo "Jenkins Initial Admin Password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

echo ""
echo "Jenkins is available on:"
echo "http://YOUR_SERVER_IP:8080"

echo ""
echo "======================================"
