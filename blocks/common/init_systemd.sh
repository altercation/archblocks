#!/bin/bash
#
# pure systemd installation
# https://wiki.archlinux.org/index.php/Systemd#A_pure_systemd_installation

pacman -S --noconfirm systemd systemd-sysvcompat
pacman -R --noconfirm initscripts

# persistent journal, self limits to default 10% of volume capacity
# https://wiki.archlinux.org/index.php/Systemd#Systemd_Journal

mkdir -p /var/log/journal
