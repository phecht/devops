#!/bin/bash

 
# This file will be in /var/lib/cloud/instances with a name
# user-data.txt. Should be a way to delete this after running.
# /var/log/cloud-init-oupt.log will have the output of user-data.txt

# update os
# dnf upgrade --releasever=2023.0.20230517

# Install Java
echo Starting install of java
dnf install java-11-amazon-corretto-devel.x86_64 -y
echo Ending install of java
# yum install java-1.8.0-openjdk.x86_64 -y

# Download and Install Jenkins
wget -O /etc/yum.repos.d/jenkins.repo     https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
dnf upgrade
yum install jenkins -y


# yum update –y
# wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat/jenkins.repo
# rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key
# yum install jenkins -y

# Start Jenkins
systemctl start jenkins

# Enable Jenkins with systemctl
systemctl enable jenkins

# Install Git SCM
yum install git -y

# Make sure Jenkins comes up/on when reboot
chkconfig jenkins on