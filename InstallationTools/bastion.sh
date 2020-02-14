#!/bin/bash

## Install Ansible in node bastion


yum update -y
yum upgrade -y
yum --enablerepo=extras install epel-release -y
yum -y  install  pyOpenSSL python-pip python-dev sshpass  python-gssapi python-crypto.x86_64
sudo -H pip install --upgrade pip
sudo -H pip install --upgrade setuptools
sudo -H pip2.7 install ansible==2.7.12
ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa
