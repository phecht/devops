#! /bin/bash

# update os
dnf upgrade --releasever=2023.0.20230517

# Install Java
sudo yum install java-11-amazon-corretto-devel.x86_64
# yum install java-1.8.0-openjdk.x86_64 -y

# Download and Install Jenkins
yum update –y
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key
yum install jenkins -y

# Start Jenkins
systemctl start jenkins

# Enable Jenkins with systemctl
systemctl enable jenkins

# Install Git SCM
yum install git -y

# Make sure Jenkins comes up/on when reboot
chkconfig jenkins on