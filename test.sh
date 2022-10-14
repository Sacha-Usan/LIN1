#!/bin/bash
echo 'Oyez Oyez'

HOSTNAME="SRV-LIN1-02"

sudo echo "$HOSTNAME" > /etc/hostname

#sudo sed -i '2s/.*/127.0.1.1\ SRV-LIN1-02' etc/hosts
