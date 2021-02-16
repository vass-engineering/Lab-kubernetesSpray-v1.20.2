#!/bin/bash

## Install Ansible in node bastion


yum update -y
yum upgrade -y
yum --enablerepo=extras install epel-release -y
yum -y  install sshpass  git
sudo mkdir -p /etc/ansible
mkdir -p /root/kubernetesSpray-v1.16.6-glusterfs/InstallationOnVagrant
yum install  -y  python3-pip
yum install -y  python36-setuptools
pip3 install --upgrade pip
pip3 install ansible==2.9.16
sudo mv /tmp/ansible.cfg /etc/ansible/
mv /tmp/ansible /root/kubernetesSpray-v1.16.6-glusterfs/InstallationOnVagrant
#sudo mv /tmp/ansible /root/
ssh-keygen -t rsa -N "" -f /root/.ssh/id_rsa

##ALLOW root login & password PasswordAuthentication

sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
systemctl restart sshd

#for host in master-one.192.168.66.2.xip.io master-two.192.168.66.3.xip.io master-three.192.168.66.4.xip.io worker-one.192.168.66.5.xip.io worker-two.192.168.66.6.xip.io worker-three.192.168.66.7.xip.io; do sshpass -f /tmp/password.txt ssh-copy-id -o "StrictHostKeyChecking no" -f $host ; done

#for host in master-one.192.168.66.2.xip.io master-two.192.168.66.3.xip.io \
#            master-three.192.168.66.4.xip.io worker-one.192.168.66.5.xip.io \
#            worker-two.192.168.66.6.xip.io worker-three.192.168.66.7.xip.io; \
#            do sshpass -f /tmp/password.txt ssh-copy-id -o "StrictHostKeyChecking no" -f $host ; done

for host in $1 $2 $3 $4 $5 $6 $7 ; do sshpass -f /tmp/password.txt ssh-copy-id -o "StrictHostKeyChecking no" -f $host ; done
