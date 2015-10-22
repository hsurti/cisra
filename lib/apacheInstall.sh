#!/bin/bash

sudo -i
yum install httpd -y
yum install php -y
cd /root
git clone https://github.com/hsurti/cisra.git
cp cisra/testws.php /var/www/html/.
service httpd start
sudo yum install mysql -y

