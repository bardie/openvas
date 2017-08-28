#!/bin/bash
############################################################################################################
#Update and Upgrade
###########################################################################################################
apt-get update
wait

############################################################################################################
#Install Nikto
###########################################################################################################

apt-get install git
wait

cd /opt/
git clone https://github.com/sullo/nikto.git
wait

############################################################################################################
#Create Directories
###########################################################################################################

mkdir -p /var/log/nikto/reports
mkdir -p /var/log/nikto/logs
mkdir -p /var/log/arachni/reports
mkdir -p /var/log/arachni/logs
mkdir -p /var/log/wapiti/reports
mkdir -p /var/log/wapiti/logs
mkdir -p /var/log/openvas/reports
mkdir -p /var/log/openvas/logs
mkdir -p /var/log/nmap/reports
mkdir -p /var/log/nmap/logs
############################################################################################################
#INSTALL ARACHNI
###########################################################################################################
apt-get install build-essential curl libcurl3 libcurl4-openssl-dev ruby ruby-dev
wait
cd /opt/
wget https://github.com/Arachni/arachni/releases/download/v1.5.1/arachni-1.5.1-0.5.12-linux-x86_64.tar.gz
wait

tar -xvf arachni-1.5.1-0.5.12-linux-x86_64.tar.gz
wait

mv arachni-1.5.1-0.5.12-linux-x86_64.tar.gz arachni/
wait

############################################################################################################
#SETUP ARACHNI
###########################################################################################################
ipaddress=$(ip route get 8.8.8.8 | head -1 | cut -d' ' -f8)
wait

nohup /opt/arachni./arachni_web -o $ipaddress > /var/log/arachni.log 2>&1 &
wait

(crontab -l ; echo "@reboot nohup /opt/arachni/./arachni_web -o $ipaddress > /var/log/arachni.log 2>&1 &")| crontab -

#Administrator account
#--------------------------
#E-mail: admin@admin.admin
#Password: administrator
#-------------------------
#Regular user account
#-------------------------
#E-mail: user@user.user
#Password: regular_user


############################################################################################################
#INSTALL WAPITI
###########################################################################################################
apt-get install wapiti
wait


############################################################################################################
#INSTALL NMAP
###########################################################################################################
apt-get install nmap
wait

############################################################################################################
#INSTALL OPENVAS
###########################################################################################################

sudo apt-get install python-software-properties
wait
sudo apt-get install sqlite3
wait
sudo add-apt-repository ppa:mrazavi/openvas
wait
sudo apt-get update
wait
sudo apt-get install openvas
wait
service  openvas-scanner start
wait
service openvas-manager start
wait
service openvas-gsa start
wait
sudo ufw allow https
wait
sudo openvas-nvt-sync
wait
PASS2=`pwgen -s 40 1`
sudo openvasmd --user=admin --new-password=$PASS2
wait

############################################################################################################
#SETUP MySQL
###########################################################################################################
#For Password Generation
apt-get install -y pwgen

#setup database
PASS=`pwgen -s 40 1`

mysql -uroot <<MYSQL_SCRIPT
CREATE DATABASE cyScan;
CREATE USER cyScan@'localhost' IDENTIFIED BY '$PASS';
GRANT ALL PRIVILEGES ON cyScan.* TO 'cyScan'@'localhost';
FLUSH PRIVILEGES;
CREATE TABLE apps (id INT NOT NULL PRIMARY KEY AUTOINCREMENT,timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,appname varchar(50),password varchar(32));
CREATE TABLE status (id INT NOT NULL PRIMARY KEY AUTOINCREMENT,timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,ip varchar(50),status varchar(50));
CREATE TABLE request (id INT NOT NULL PRIMARY KEY AUTOINCREMENT,timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,company varchar(50),assets TEXT,status varchar(50),scantype varchar(50));
CREATE TABLE status (id INT NOT NULL PRIMARY KEY AUTOINCREMENT,timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,user varchar(10),password varchar(32),prePassword varchar(32),lockoutcount INT(2),lockoutstatus varchar(10),company varchar(50));
MYSQL_SCRIPT

user="cyScan"
psw="$PASS"
database="cyScan"

echo "INSERT INTO apps (appname, password) values ('"MySQL"',SHA256('".$PASS."'));" | mysql -sN --user=${user} --password=${psw} ${database};
echo "INSERT INTO apps (appname, password) values ('"OpenVas"',SHA256('".$PASS2."'));" | mysql -sN --user=${user} --password=${psw} ${database};


############################################################################################################
#VULNtoES setup
###########################################################################################################
cd /opt/
wait
git clone https://github.com/ChrisRimondi/VulntoES
wait
