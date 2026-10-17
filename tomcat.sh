
#!/bin/bash
set -e

# Update packages
sudo apt update

# Install Java
sudo apt install -y openjdk-17-jdk curl

# Set Tomcat version
TOMCAT_VERSION="10.1.52"
TOMCAT_USER="tomcat"

# Create Tomcat user
if ! id "$TOMCAT_USER" &>/dev/null; then
    sudo useradd -r -m -U -d /opt/tomcat \
        -s /usr/sbin/nologin "$TOMCAT_USER"
fi

# Download and extract Tomcat
cd /tmp
curl -fLO "https://archive.apache.org/dist/tomcat/tomcat-10/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz"

sudo mkdir -p /opt/tomcat
sudo tar -xzf "apache-tomcat-${TOMCAT_VERSION}.tar.gz" \
    -C /opt/tomcat --strip-components=1

# Set permissions
sudo chown -R tomcat:tomcat /opt/tomcat
sudo chmod +x /opt/tomcat/bin/*.sh

# Create systemd service
sudo tee /etc/systemd/system/tomcat.service > /dev/null <<'EOF'
[Unit]
Description=Apache Tomcat Server
After=network.target

[Service]
Type=forking
User=tomcat
Group=tomcat
Environment="JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64"
Environment="CATALINA_HOME=/opt/tomcat"
Environment="CATALINA_BASE=/opt/tomcat"
ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Start Tomcat
sudo systemctl daemon-reload
sudo systemctl enable --now tomcat

echo "Tomcat installation completed!"
echo "Service status:"
sudo systemctl status tomcat --no-pager
echo "Access: http://SERVER_PUBLIC_IP:8080"
