#!/bin/bash

########################
# Configuration OpenLDAP

dpkg-reconfigure slapd

# Omit OpenLDAP server configuration ? : Non
# DNS domain name : lin1.local
# Organization name : lin1.local
# Administrator password : Pa$$w0rd
# Confirm password : Pa$$w0rd
# Do you want the database to be removed when slapd is purged ? : Non
# Move old database ? : Oui

##################################
# Vérification de la configuration

slapcat

##############################
# Redémarrage du service slapd

systemctl restart slapd
systemctl status slapd
