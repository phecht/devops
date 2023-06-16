#! /bin/bash

# Install Java
echo Starting install of java
dnf install java-1.8.0-amazon-corretto.x86_64 -y -q
echo Ending install of java

# Update the packages
dnf update –y
# Download Nexus

mkdir /app && cd /app
# Wget the tar file
wget -nv -O  nexus.tar.gz https://download.sonatype.com/nexus/3/latest-unix.tar.gz
# Unzip/Untar the compressed file
tar -xvf nexus.tar.gz
# Rename folder for ease of use
mv nexus-3* nexus
# Enable permission for ec2-user to work on nexus and sonatype-work folders
chown -R ec2-user:ec2-user nexus/ sonatype-work/
# Setup user and directory permission
adduser nexus
chown -R nexus:nexus /app/nexus /app/sonatype-work
# Add nexus as a service at boot time
ln -s /app/nexus/bin/nexus /etc/init.d/nexus
# systemctl nexus start

chkconfig --add nexus
chkconfig --levels 345 nexus on
# Start Nexus
sudo su nexus
service nexus start
