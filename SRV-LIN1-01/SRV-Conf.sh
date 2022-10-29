#!/bin/bash

####################################
# Implémentation de la clef publique

mkdir /home/cpnv/.ssh
chmod 755 /home/cpnv/.ssh
touch /home/cpnv/.ssh/authorized_keys

cat << EOM > /home/cpnv/.ssh/authorized_keys
ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBKtwmkAffyMfwgGnw+kgfgNHPmElZj9qMUlXPnQibizA/tzO3UEWapFiq1/0Rc6h2ixJFLvKeef5NnFo1AMDWNg= ecdsa-key-20221015
EOM

cat << EOM > /etc/ssh/sshd_config
Include /etc/ssh/sshd_config.d/*.conf

PasswordAuthentication yes
PermitEmptyPasswords no

ChallengeResponseAuthentication no

UsePAM yes

X11Forwarding yes

PrintMotd no

AcceptEnv LANG LC_*

Subsystem       sftp    /usr/lib/openssh/sftp-server
EOM

#############################
# Définition du nom de l'hôte

hostnamectl set-hostname SRV-LIN1-01

###########################
# Définition de l'interface

cat << EOM > /etc/network/interfaces
source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto enp0s3
iface enp0s3 inet static
address 10.10.10.11
netmask 255.255.255.0
gateway 10.10.10.1
EOM

##########################
# Définition fichier hosts

cat << EOM > /etc/hosts
127.0.0.1       localhost
127.0.1.1       SRV-LIN1-01
10.10.10.11     SRV-LIN1-01.lin1.local SRV-LIN1-01

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOM

#########################################
# Définition du fichier de résolution DNS

cat << EOM > /etc/resolv.conf
domain lin1.local
search lin1.local
nameserver 10.10.10.11
nameserver 10.10.10.1
EOM
