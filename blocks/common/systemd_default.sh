#!/bin/bash
#
# INIT - systemd, pure
# as per the Arch Linux wiki page on systemd: https://wiki.archlinux.org/index.php/Systemd

_anykey ">>>>>>>>>>>SYSTEMD TEST"

_installpkg systemd
pacman -R --noconfirm sysvinit
_anykey ">>>>>>>>>>>SYSTEMD TEST"

pacman -S --noconfirm systemd-sysvcompat
_anykey ">>>>>>>>>>>SYSTEMD TEST"

pacman -R --noconfirm initscripts # going for pure systemd
_anykey ">>>>>>>>>>>SYSTEMD TEST"


# NOT NEEDED IN PURE SYSTEMD MODE
# KERNEL_PARAMS="${KERNEL_PARAMS:+${KERNEL_PARAMS} }init=/bin/systemd"

systemctl enable syslog-ng.service

