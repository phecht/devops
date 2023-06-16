#!/bin/bash

# install pip
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python3 get-pip.py 

# install ansible
python3 -m pip install ansible


sudo useradd ansibleadmin

sudo echo "shorta7!" | sudo passwd --stdin ansibleadmin
echo 'ansibleadmin     ALL=(ALL)      NOPASSWD: ALL' | sudo tee -a /etc/sudoers


sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config

sudo service sshd restart
