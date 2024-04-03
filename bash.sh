#!/bin/bash
DB_HOST="database.cheelndqlyie.us-east-1.rds.amazonaws.com"
DB_NAME="wordpress"
DB_USER="avinash"
DB_PASSWORD="database"

sudo yum update -y
sudo yum install -y mysql httpd
sudo amazon-linux-extras install -y php8.2

sudo systemctl start httpd
sudo systemctl enable httpd

sudo mysql -h $DB_HOST -u $DB_USER -p$DB_PASSWORD -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"
sudo mysql -h $DB_HOST -u $DB_USER -p$DB_PASSWORD -e "CREATE USER IF NOT EXISTS '$DB_USER' IDENTIFIED BY '$DB_PASS';"
sudo mysql -h $DB_HOST -u $DB_USER -p$DB_PASSWORD -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER';"
sudo mysql -h $DB_HOST -u $DB_USER -p$DB_PASSWORD -e "FLUSH PRIVILEGES;"

sudo wget https://wordpress.org/latest.tar.gz
sudo tar -zxvf latest.tar.gz -C /home/ec2-user/

sudo mv /home/ec2-user/wordpress/wp-config-sample.php /home/ec2-user/wordpress/wp-config.php
sudo sed -i "s/database_name_here/$DB_NAME/g" /home/ec2-user/wordpress/wp-config.php
sudo sed -i "s/username_here/$DB_USER/g" /home/ec2-user/wordpress/wp-config.php
sudo sed -i "s/password_here/$DB_PASSWORD/g" /home/ec2-user/wordpress/wp-config.php
sudo sed -i "s/localhost/$DB_HOST/g" /home/ec2-user/wordpress/wp-config.php

sudo curl -sS https://api.wordpress.org/secret-key/1.1/salt/ | sudo tee -a /home/ec2-user/wordpress/wp-config.php >/dev/null

sudo cp -Rf /home/ec2-user/wordpress/* /var/www/html/

sudo systemctl restart httpd
