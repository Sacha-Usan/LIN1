#!/bin/bash

#######################
# Installation OpenLDAP

apt update -y && sudo apt upgrade -y
apt install slapd ldap-utils -y

# Administrator password : Pa$$w0rd
# Confirm password : Pa$$w0rd

#############################
# Configuration fichier hosts

cat << EOM > /etc/hosts
127.0.0.1       localhost
10.10.10.11     SRV-LIN1-01.lin1.local  SRV-LIN1-01 ldap

# The following lines are desirable for IPv6 capable hosts
::1     localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOM
