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

mv /etc/acpi/handler.sh /etc/acpi/handler.sh.prethinkpad
cat > /etc/acpi/handler.sh << EOF
#!/bin/bash

set $*

case $2 in
#VOLDN) dispatch volume down ;;
#VOLUP) dispatch volume up ;;
MUTE) dispatch volume toggle ;;
ZOOM) ;;
CDSTOP) ;;
CDPREV) ;;
CDPLAY) ;;
CDNEXT) ;;
BRTDN) ;;
BRTUP) ;;
VMOD) ;;
WLAN) ;;
BAT) dispatch power cycle ;;
#BAT) dispatch power toggle ;;
PROG1) dispatch power mov ;; # thinkvantage button
SCRNLCK) system lock ;;
PBTN) ;; # power button
SBTN) ;; # sleep button
SUSP) ;; # suspend button
LID) case $3 in open) : ;; close) : ;; esac ;;
TBLT) case $3 in on) : ;; off) : ;; esac ;; # rotate to tablet mode
LEN0068:00) case $3 in
	0000500c) ;; # undock tablet pen
	0000500b) ;; # dock tablet pen
	00004011) ;; # undock battery
	00004010) ;; # dock battery
esac ;;
esac


EOF
