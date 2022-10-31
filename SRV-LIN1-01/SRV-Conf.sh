#!/bin/bash

####################################
# Implémentation de la clef publique

mkdir /home/cpnv/.ssh
chmod 755 /home/cpnv/.ssh
touch /home/cpnv/.ssh/authorized_keys

cat << EOM > /home/cpnv/.ssh/authorized_keys
ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBGKTVL5KJxOEZexMz7uZgXTPbF9D5ZIADg0XTYzx56qw61aODbldQuKIOAZCxttxFhrP5jKIZ/qE1N7IrTqPDVM= ecdsa-key-20221031
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
