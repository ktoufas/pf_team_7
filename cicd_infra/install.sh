#! /bin/bash

#Update
sudo yum update -y

#Install Jenkins
sudo wget -O /etc/yum.repos.d/jenkins.repo \
https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo yum upgrade -y
sudo yum install java-1.8.0 jenkins maven -y
sudo systemctl daemon-reload

#Configure system to redirect port 80 to jenkins used port 8080
sudo yum install -y iptables-services
sudo systemctl enable iptables
sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8080
sudo /usr/libexec/iptables/iptables.init save #SAVE REDIRECTION#

#Install docker
yum install -y docker
sudo systemctl start docker
sudo systemctl start containerd
sudo systemctl enable docker
sudo systemctl enable containerd

#Add Jenkins user to docker group
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins

#Install ansible
sudo amazon-linux-extras install -y epel
sudo yum install -y ansible

#install git
sudo yum install -y git
