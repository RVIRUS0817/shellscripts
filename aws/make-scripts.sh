#!/bin/bash

sudo dd if=/dev/zero of=/swapfile1 bs=1M count=2024
sudo chmod 600 /swapfile1
sudo mkswap /swapfile1
sudo swapon /swapfile1
sudo sh -c 'echo "/swapfile1  none        swap    sw              0   0" >> /etc/fstab'
