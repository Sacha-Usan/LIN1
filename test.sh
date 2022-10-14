#!/bin/bash
echo 'Oyez Oyez'

NEW_HOSTNAME="SRV-LIN1-02"

# sudo echo "$NEW_HOSTNAME" > /etc/hostname
# sudo bash -c 'echo "$NEW_HOSTNAME" > /etc/hostname'
sudo bash -c 'echo "$NEW_HOSTNAME"'

# sudo sed -i '2s/.*/127.0.1.1\ SRV-LIN1-02' etc/hosts
# sudo bash -c "sed -i '2s/.*/127.0.0.1\ $HOSTNAME/' /etc/hosts"
