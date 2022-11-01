#!/bin/bash

#################################
# Définissez votre nom de domaine

my_domain="SRV-LIN1-01.lin1.local"
echo $my_domain

hostnamectl set-hostname $my_domain
hostname -f

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
# uncommment the line below if variable was set
#ServerName $my_domain
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
occ config:system:set trusted_domains 2 --value="$my_domain"

############################
# Configurer les tâches cron

occ background:cron

echo "*/15  *  *  *  * /var/www/owncloud/occ system:cron" \
  | sudo -u www-data -g crontab tee -a \
  /var/spool/cron/crontabs/www-data
echo "0  2  *  *  * /var/www/owncloud/occ dav:cleanup-chunks" \
  | sudo -u www-data -g crontab tee -a \
  /var/spool/cron/crontabs/www-data

echo "1 */6 * * * /var/www/owncloud/occ user:sync \
  'OCA\User_LDAP\User_Proxy' -m disable -vvv >> \
  /var/log/ldap-sync/user-sync.log 2>&1" \
  | sudo -u www-data -g crontab tee -a \
  /var/spool/cron/crontabs/www-data
mkdir -p /var/log/ldap-sync
touch /var/log/ldap-sync/user-sync.log
chown www-data. /var/log/ldap-sync/user-sync.log

#############################################################
# Configurer la mise en cache et le verrouillage des fichiers

occ config:system:set \
   memcache.local \
   --value '\OC\Memcache\APCu'
occ config:system:set \
   memcache.locking \
   --value '\OC\Memcache\Redis'
occ config:system:set \
   redis \
   --value '{"host": "127.0.0.1", "port": "6379"}' \
   --type json

#####################################
# Configurer la rotation des journaux

sudo cat << EOM > /etc/logrotate.d/owncloud
/var/www/owncloud/data/owncloud.log {
  size 10M
  rotate 12
  copytruncate
  missingok
  compress
  compresscmd /bin/gzip
}
EOM

##########################
# Finaliser l'installation

cd /var/www/
chown -R www-data. owncloud

occ -V
echo "Your Admin password is: "$sec_admin_pwd
echo "It's documented at /etc/.sec_admin_pwd.txt"
echo "Your Database Password is: "$sec_db_pwd
echo "It's documented at /etc/.sec_db_pwd.txt and in your config.php"
echo "Your ownCloud is accessable under: "$my_domain
echo "The Installation is complete."
