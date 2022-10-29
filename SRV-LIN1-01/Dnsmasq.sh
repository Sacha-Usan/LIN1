#!/bin/bash

####################################
# Configuration du fichier Dnsmasq

cat << EOM > /etc/dnsmasq.conf
domain-needed
local=/lin1.local/
interface=enp0s3
listen-address=10.10.10.11
domain=lin1.local

dhcp-range=10.10.10.110,10.10.10.119,255.255.255.0,72h
dhcp-option=3,10.10.10.11
dhcp-option=40,lin1.local

#Zone Directe
address=/srv-lin1-01.lin1.local/srv-lin1-01/10.10.10.11
address=/srv-lin1-02.lin1.local/srv-lin1-02/10.10.10.22
address=/nas-lin1-01.lin1.local/nas-lin1-01/10.10.10.33

#Zone Inverse
ptr-record=11.10.10.10.in-addr-arpa.,"srv-lin1-01"
ptr-record=22.10.10.10.in-addr-arpa.,"srv-lin1-02"
ptr-record=33.10.10.10.in-addr-arpa.,"nas-lin1-01"
EOM
