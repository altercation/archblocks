#!/bin/bash

# current x220 related archlinux tweaks/patches

# watchdog error at boot: (itco_wdt cannot register miscdev on minor)
# https://bbs.archlinux.org/viewtopic.php?id=133083

# echo blacklist mei > /etc/modprobe.d/mei.conf



# boot error: Unknown user uuidd
# _anykey "Please reinstall util-linux after reboot to eliminate uuidd related error"
# pacman -Syu util-linux


_installaur thinkfan
sudo systemctl enable thinkfan.service
echo "options thinkpad_acpi fan_control=1" > /etc/modprobe.d/thinkfan.conf

# enable blinking wifi led
cat > /etc/modprobe.d/iwlwifi.conf << EOF
# led_mode=0 - led_mode:0=system default, 1=On(RF On)/Off(RF Off), 2=blinking, 3=Off (default: 0) (int)
options iwlwifi led_mode=2
options iwlwifi power_save=1
EOF
