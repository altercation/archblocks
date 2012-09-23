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
#[ -f "$0" ] || cat "$0" > /tmp/archblocks.sh && \
#( [ -n $DEBUG ] && bash -x /tmp/archblocks.sh || sh /tmp/archblocks.sh )
if [ ! -f "$0" ]; then # we're redirecting curl output
cat "$0" > /tmp/archblocks.sh # write to a file
[ -n $DEBUG ] && bash -x /tmp/archblocks.sh || sh /tmp/archblocks.sh
exit
fi

#set -o errexit; set -o nounset # buckle up
set -o errexit
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

# if we haven't installed yet
if [ -z ${INCHROOT:-} ] && [ ! -d "${MOUNT_PATH/%\//}/etc" ]; then
LoadBlock WARN_impending_doom
LoadBlock PREFLIGHT_default
LoadBlock FILESYSTEM_gpt_luks_ext4_root
FILESYSTEM_PRE_BASEINSTALL # make filesystem
LoadBlock BASEINSTALL_pacstrap
FILESYSTEM_POST_BASEINSTALL # write configs
FILESYSTEM_PRE_CHROOT # unmount efi boot part
CHROOT_CONTINUE
fi

# if we are in chroot
#if [ -n ${INCHROOT:-} ]; then
if [ -n ${INCHROOT:-} ] && [ ! -d "${MOUNT_PATH/%\//}/etc" ]; then
# load fs again since chroot is new and we need fs variables in bootloader
# todo make pre-bootloader function which generalizes the variable used by
# bootloader. we also need to run the post chroot filesystem function.
LoadBlock FILESYSTEM_gpt_luks_ext4_root
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
unset INCHROOT
fi

exit

# ready to rock
if [ -z ${INCHROOT:-} ]; then # OUT OF CHROOT; WRAP UP
echo "WRAP UP"
exit
#UNMOUNT_REBOOT
fi

