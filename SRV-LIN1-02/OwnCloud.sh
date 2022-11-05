#!/bin/bash

#################################
# Générer des mots de passe forts

sec_admin_pwd=$(openssl rand -base64 18)
echo $sec_admin_pwd > /etc/.sec_admin_pwd.txt

sec_db_pwd=$(openssl rand -base64 18)
echo $sec_db_pwd > /etc/.sec_db_pwd.txt

apt update -y && apt upgrade -y

##################################
# Créer le script d'assistance occ

cat << EOM > /usr/local/bin/occ
#! /bin/bash
cd /var/www/owncloud
sudo -E -u www-data /usr/bin/php /var/www/owncloud/occ "\$@"
EOM

chmod +x /usr/local/bin/occ

###############################
# Installer les packages requis

sudo add-apt-repository ppa:ondrej/php -y
sudo apt update && sudo apt upgrade

apt install -y \
  apache2 \
  libapache2-mod-php7.4 \
  mariadb-server openssl redis-server wget \
  php7.4 php7.4-imagick php7.4-common php7.4-curl \
  php7.4-gd php7.4-imap php7.4-intl php7.4-json \
  php7.4-mbstring php7.4-gmp php7.4-bcmath php7.4-mysql \
  php7.4-ssh2 php7.4-xml php7.4-zip php7.4-apcu \
  php7.4-redis php7.4-ldap php-phpseclib\
  
####################################
# Installer les packages recommandés

apt install -y \
  unzip bzip2 rsync curl jq \
  inetutils-ping  ldap-utils\
  smbclient

########################################
# Configurer Apache
# Créer une configuration d'hôte virtuel

cat << EOM > /etc/apache2/sites-available/owncloud.conf
<VirtualHost *:80>
DirectoryIndex index.php index.html
DocumentRoot /var/www/owncloud
<Directory /var/www/owncloud>
  Options +FollowSymlinks -Indexes
  AllowOverride All
  Require all granted

 <IfModule mod_dav.c>
  Dav off
 </IfModule>

 SetEnv HOME /var/www/owncloud
 SetEnv HTTP_HOME /var/www/owncloud
</Directory>
</VirtualHost>
EOM

############################################
# Activer la configuration de l'hôte virtuel

a2dissite 000-default
a2ensite owncloud.conf

###############################
# Configurer la base de données

sed -i "/\[mysqld\]/atransaction-isolation = READ-COMMITTED\nperformance_schema = on" /etc/mysql/mariadb.conf.d/50-server.cnf
systemctl start mariadb
mysql -u root -e "CREATE DATABASE IF NOT EXISTS owncloud; \
GRANT ALL PRIVILEGES ON owncloud.* \
  TO owncloud@localhost \
  IDENTIFIED BY '${sec_db_pwd}'";

########################################
# Activer les modules Apache recommandés

a2enmod dir env headers mime rewrite setenvif
systemctl restart apache2

######################
# Installation
# Télécharger ownCloud

cd /var/www/
wget https://download.owncloud.com/server/stable/owncloud-complete-latest.tar.bz2 && \
tar -xjf owncloud-complete-latest.tar.bz2 && \
chown -R www-data. owncloud

####################
# Installer ownCloud

occ maintenance:install \
    --database "mysql" \
    --database-name "owncloud" \
    --database-user "owncloud" \
    --database-pass ${sec_db_pwd} \
    --data-dir "/var/www/owncloud/data" \
    --admin-user "admin" \
    --admin-pass ${sec_admin_pwd}

#################################################
# Configurer les domaines de confiance d'ownCloud

my_ip=$(hostname -I|cut -f1 -d ' ')
occ config:system:set trusted_domains 1 --value="$my_ip"
occ config:system:set trusted_domains 2 --value="srv-lin1-02"
occ config:system:set trusted_domains 3 --value="lin1.local"

##########################
# Finaliser l'installation

occ -V
echo "Your Admin password is: "$sec_admin_pwd
echo "It's documented at /etc/.sec_admin_pwd.txt"
echo "Your Database Password is: "$sec_db_pwd
echo "It's documented at /etc/.sec_db_pwd.txt and in your config.php"
echo "Your ownCloud is accessable under: lin1.local"
echo "The Installation is complete."
