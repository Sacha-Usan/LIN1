#!/bin/bash
echo 'Oyez Oyez'

HOSTNAME="SRV-LIN1-02"

#sudo echo "$HOSTNAME" > /etc/hostname
sudo bash -c 'echo "$HOSTNAME" > /etc/hostname'

#sudo sed -i '2s/.*/127.0.1.1\ SRV-LIN1-02' etc/hosts
sudo bash -c "sed -i '2s/.*/127.0.0.1\ $HOSTNAME/' /etc/hosts"
