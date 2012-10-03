#!/bin/bash

# current x220 related archlinux tweaks/patches

# watchdog error at boot: (itco_wdt cannot register miscdev on minor)
# https://bbs.archlinux.org/viewtopic.php?id=133083

echo blacklist mei > /etc/modprobe.d/mei.conf

# boot error: Unknown user uuidd
_anykey "Please reinstall util-linux after reboot to eliminate uuidd related error"
# pacman -Syu util-linux
