#!/bin/bash
set -euo pipefail

TOMCAT_VERSION="9.0.100"  # Or your desired 9.x version
INSTALL_DIR="/opt/tomcat"

# 1. Install Java 21 and curl
sudo apt update -y
sudo apt install -y openjdk-21-jdk-headless curl tar

# 2. Download from the permanent Apache Archive (avoids 404 errors)
echo "Downloading Tomcat ${TOMCAT_VERSION}..."
curl -fsSL "https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz" -o /tmp/tomcat.tar.gz

# 3. Extract to /opt/tomcat
sudo mkdir -p "${INSTALL_DIR}"
sudo tar -xzf /tmp/tomcat.tar.gz -C "${INSTALL_DIR}" --strip-components=1
rm -f /tmp/tomcat.tar.gz

# 4. Safely configure tomcat-users.xml (clean rewrite, no line-number hacks)
sudo tee "${INSTALL_DIR}/conf/tomcat-users.xml" > /dev/null <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<tomcat-users xmlns="http://tomcat.apache.org/xml"
              xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
              xsi:schemaLocation="http://tomcat.apache.org/xml tomcat-users.xsd"
              version="1.0">
  <role rolename="manager-gui"/>
  <role rolename="manager-script"/>
  <user username="tomcat" password="admin@123" roles="manager-gui,manager-script"/>
</tomcat-users>
EOF

# 5. Allow remote access to the Manager App (remove Valve IP restrictions)
sudo mkdir -p "${INSTALL_DIR}/webapps/manager/META-INF"
sudo tee "${INSTALL_DIR}/webapps/manager/META-INF/context.xml" > /dev/null <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<Context privileged="true" antiResourceLocking="false">
  <Valve className="org.apache.catalina.valves.RemoteAddrValve"
         allow=".*" />
</Context>
EOF

# 6. Make scripts executable and start Tomcat
sudo chmod +x "${INSTALL_DIR}/bin/"*.sh
sh "${INSTALL_DIR}/bin/startup.sh"

# 7. Verification
sleep 3
ps -ef | grep tomcat | grep -v grep
ss -tlnp | grep 8080
