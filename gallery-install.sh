#!/usr/bin/env bash
# gallery-install.sh
# installs sigal and images for demo website
# Runs on: CentOS 7 Python3
# author: Brian King
# copyright: 2020
# version: 0.0.3a
# license: Apache
# last modified: 2020-05-01

yum -y install python3-pip > /dev/null 2>&1
easy_install-3.6 pip3 > /dev/null 2>&1
pip3 install sigal > /dev/null 2>&1
wget -qO /tmp/litarcades.zip https://50900a4f92b974ff9ce5-94a2eb82dea24a44a5848a3c12a70fa8.ssl.cf2.rackcdn.com/litarcades.zip
mkdir -p /var/www/$domain/pictures
mkdir /var/www/$domain/pictures
unzip /tmp/litarcades.zip -d /var/www/$domain/pictures
/usr/local/bin/sigal init /var/www/$domain/sigal.conf.py > /dev/null 2>&1
/usr/local/bin/sigal build -c  /var/www/$domain/sigal.conf.py /var/www/$domain/pictures /var/www/$domain/  > /dev/null 2>&1
mkdir -p /var/www/$domain
mkdir -p /etc/httpd/conf.d/
cat > /etc/httpd/conf.d/$domain.conf << EOF
<VirtualHost *:80>
ServerName $domain
<Directory /var/www/$domain>
Require all granted
</Directory>
DocumentRoot /var/www/$domain
LogFormat "%{X-Forwarded-For}i %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" forwarded
SetEnvIf X-Forwarded-For "^.*\..*\..*\..*" forwarded
CustomLog "logs/access_log" combined env=!forwarded
CustomLog "logs/access_log" forwarded env=forwarded
</VirtualHost>
EOF
systemctl start httpd; systemctl enable httpd
systemctl stop firewalld; systemctl mask firewalld; iptables -F; systemctl start iptables; systemctl enable iptables
iptables -I INPUT 1 -m multiport -p tcp --dports http,https -j ACCEPT
iptables-save > /etc/sysconfig/iptables