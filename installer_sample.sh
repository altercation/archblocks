#!/bin/bash
# ------------------------------------------------------------------------
# archblocks - modular Arch Linux install script
# ------------------------------------------------------------------------
# http://github.com/altercation/archblocks
# es@ethanschoonover.com @ethanschoonover https://github.com/altercation

# ------------------------------------------------------------------------
# INSTRUCTIONS: boot into Arch Install media and run:
# sh <(curl -sfL https://raw.github.com/altercation/archblocks/master/installer_sample.sh)
# ------------------------------------------------------------------------
# alternate short url:
# sh <(curl -sfL http://git.io/7PEHOg

DEBUG=true

# if running via curl, copy self to local file first
[ -f "$0" ] || cat "$0" > /tmp/archblocks.sh && \
( [ -n $DEBUG ] && bash -x /tmp/archblocks.sh || sh /tmp/archblocks.sh )

#set -o errexit; set -o nounset # buckle up
RAW_REPO_URL=https://raw.github.com/altercation/archblocks/master/
. /dev/stdin <<< "$(curl -f -s ${RAW_REPO_URL}/lib/functions.sh)"

HOSTNAME=tau
SYSTEMTYPE=thinkpad_x220
USERNAME=es
USERSHELL=/bin/bash
FONT=Lat2-Terminus16
LANGUAGE=en_US.UTF-8
KEYMAP=us
TIMEZONE=US/Pacific
MODULES="dm_mod dm_crypt aes_x86_64 ext2 ext4 vfat intel_agp drm i915"
HOOKS="usb usbinput consolefont encrypt filesystems"
#DRIVE=/dev/sda (default depends on FILESYSTEM block)

if [ -z ${INCHROOT:-} ]; then # NOT IN CHROOT; PREINSTALL PREP
LoadBlock WARN_impending_doom
LoadBlock PREFLIGHT_default
LoadBlock FILESYSTEM_gpt_luks_ext4_root
FILESYSTEM_PRE_BASEINSTALL # make filesystem
LoadBlock BASEINSTALL_pacstrap
FILESYSTEM_POST_BASEINSTALL # write configs
FILESYSTEM_PRE_CHROOT # unmount efi boot part
echo "MANUAL TEST"
exit
CHROOT_CONTINUE
exit
fi

if [ -n ${INCHROOT:-} ]; then # IN CHROOT; INSTALL & CONFIG
FILESYSTEM_POST_CHROOT # remount efi boot part
LoadBlock LOCALE_default
LoadBlock TIME_ntp
LoadBlock DAEMONS_default
LoadBlock HOSTNAME_default
LoadBlock NETWORK_wired_wireless_minimal
LoadBlock KERNEL_default
LoadBlock RAMDISK_default
LoadBlock BOOTLOADER_efi_gummiboot
LoadBlock POSTFLIGHT_add_sudo_user 
LoadBlock POWER_acpi # could be system specific
LoadBlock AUDIO_alsa_basic
LoadBlock VIDEO_mesa_basic
#LoadBlock XORG_wacom_fonts
#LoadBlock DESKTOP_xmonad-minimal
#LoadBlock SYSTEM_${SYSTEMTYPE} # other system tweaks for specific hw
#LoadBlock UTILS_${USERNAME}
#LoadBlock HOMESETUP_${USERNAME}
fi

# ready to rock
if [ -z ${INCHROOT:-} ]; then # OUT OF CHROOT; WRAP UP
UNMOUNT_REBOOT
fi
