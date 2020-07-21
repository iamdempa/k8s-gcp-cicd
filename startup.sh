#!/bin/bash
sudo apt-get update
sudo apt-get upgrade -y
sudo apt install ansible -y
echo `cat /root/.ssh/id_rsa.pub` >> /root/.ssh/authorized_keys