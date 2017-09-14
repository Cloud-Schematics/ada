#!/bin/bash -v

# for CENTOS 7
yum install epel-release
yum -y install nginx
service nginx start
systemctl enable nginx

# for Debian / Ubuntu
#apt-get update -y
#apt-get install -y nginx > /tmp/nginx.log
#service nginx start
