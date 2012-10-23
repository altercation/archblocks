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

# ACPI HANDLER --------------------------------------------------------
mv /etc/acpi/handler.sh /etc/acpi/handler.sh.prethinkpad
cat > /etc/acpi/handler.sh << EOF
#!/bin/bash

set $*

case $1 in
ac_adapter) /usr/bin/power auto ;; # unplug or plug ac cord
esac

case $2 in

#VOLDN) /usr/bin/volume down ;; # handling in xmonad
#VOLUP) /usr/bin/volume up ;; # handling in xmonad
#MUTE) /usr/bin/volume toggle ;; # handling in xmonad

CDSTOP) ;;
CDPREV) ;;
CDPLAY) ;;
CDNEXT) ;;

BRTDN) ;;
BRTUP) ;;
VMOD) ;;

WLAN) ;; # handled by bios
F24) /usr/bin/wireless bluetooth toggle ;; # fn-F9
FF11) : ;; # fn-F11
PROG1) ;; # thinkvantage button

ZOOM) ;;

SCRNLCK) /usr/bin/display lock; ;;
BAT) /usr/bin/power cycle; ;;
PBTN)
     if [ "$(cat /sys/devices/platform/thinkpad_acpi/hotkey_tablet_mode)" -gt 0 ];
     then /usr/bin/display tablet on
     else /usr/bin/power off; fi
;;
SBTN) /usr/bin/power sleep ;; # sleep button
SUSP) /usr/bin/power reboot ;; # suspend button (hibernate)
LID) case $3 in open) : ;; close) /usr/bin/power sleep ;; esac ;;
TBLT) case $3 in on) /usr/bin/display tablet on ;; off) /usr/bin/display tablet off ;; esac ;; # rotate to tablet mode

LEN0068:00) case $3 in
	0000500c) ;; # undock tablet pen
	0000500b) ;; # dock tablet pen
	00004011) ;; # undock battery
	00004010) ;; # dock battery
        esac ;;
esac
EOF

# SYSTEMD LOGIND.CONF -------------------------------------------------

# we're going to handle power events in acpi for now
cat >> /etc/systemd/logind.conf << EOF
HandlePowerKey=ignore
HandleSuspendKey=ignore
HandleHibernateKey=ignore
HandleLidSwitch=ignore
EOF
