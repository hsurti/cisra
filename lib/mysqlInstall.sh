#!/bin/bash

sudo rpm -Uvh http://dev.mysql.com/get/mysql-community-release-el7-5.noarch.rpm
sudo yum install mysql-server -y
sudo /sbin/service mysqld start
#sudo /usr/bin/mysql_secure_installation
#sudo yum install mariadb-server mariadb
sudo iptables -I INPUT -p tcp --dport 3306 -m state --state NEW,ESTABLISHED -j ACCEPT
sudo iptables -I OUTPUT -p tcp --sport 3306 -m state --state ESTABLISHED -j ACCEPT
mysqladmin -u root password rootpwd
cat << EOF | mysql -u root --password=rootpwd
CREATE DATABASE cis;
create user 'cisuser'@'localhost' identified by 'cispwd';
grant all privileges on *.* to 'cisuser'@'localhost';
grant all privileges on *.* to 'cisuser'@'%' identified by 'cispwd';
grant all privileges on *.* to 'cisuser'@'%' with grant option;
commit;
FLUSH PRIVILEGES;
EXIT
EOF
