#!/bin/bash
dnf update -y
dnf install git -y
dnf install pip -y
pip install flask
# install mysqlclient dependencies
dnf install -y mariadb105-devel gcc python3-devel
pip install mysqlclient
cd /home/ec2-user
git clone ${git-repo}
cd ./202-Terraform-Phonebook-Application-deployed-on-AWS
rm -rf tf-files tf-ssm-files
# set config file for flask-mysql connection
echo -e "[client]\nhost = ${db-endpoint}\ndatabase = ${db-name}\nuser = ${db-user}\npassword = ${db-pass}\nport = ${db-port}"  > ./my.cnf
python3 phonebook-app.py