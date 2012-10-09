#!/bin/bash
#
# INIT - systemd, pure
# as per the Arch Linux wiki page on systemd: https://wiki.archlinux.org/index.php/Systemd

_installpkg systemd
pacman -S systemd-sysvcompat # interactive
pacman -R initscripts # going for pure systemd

# NOT NEEDED IN PURE SYSTEMD MODE
# KERNEL_PARAMS="${KERNEL_PARAMS:+${KERNEL_PARAMS} }init=/bin/systemd"

systemctl enable syslog-ng.service

