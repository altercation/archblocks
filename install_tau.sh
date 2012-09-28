#!/bin/bash
# ------------------------------------------------------------------------
# archblocks - modular Arch Linux install script
# ------------------------------------------------------------------------
# es@ethanschoonover.com @ethanschoonover https://github.com/altercation
# http://github.com/altercation/archblocks

# INSTRUCTIONS -----------------------------------------------------------
# boot into Arch Install media and run (for this script only):
#
# curl -sfL https://raw.github.com/altercation/archblocks/master/install_tau.sh" > install.sh; sh install.sh
#
# or use git.io / other shortener to create a short url
#
# curl -sfL http://git.io/rQx7Xw > install.sh; sh install.sh

# CONFIG -----------------------------------------------------------------
REMOTE=https://raw.github.com/altercation/archblocks/master
HOSTNAME=tau
SYSTEMTYPE=thinkpad_x220
USERNAME=es
USERSHELL=/bin/bash
FONT=Lat2-Terminus16
LANGUAGE=en_US.UTF-8
KEYMAP=us
TIMEZONE=US/Pacific
MODULES="dm_mod dm_crypt aes_x86_64 ext2 ext4 vfat intel_agp drm i915"
HOOKS="base udev autodetect pata scsi sata usb usbinput consolefont encrypt filesystems fsck"
KERNEL_PARAMS="quiet" # set/used in FILESYSTEM,INIT,BOOTLOADER blocks
DRIVE=/dev/sda # this overrides any default value set in FILESYSTEM block

# LOAD HELPER FUNCTIONS (local if avail, remote otherwise) ---------------
LoadFailCheck () { exit 1; }; [ -f "$(dirname $0)/blocks/${_LIB}" ] \
&& URL="file://blocks/_LIB.sh" || URL="${REMOTE/%\//}/blocks/_LIB.sh";
eval "$(curl -fsL ${URL})"; LoadFailCheck

if $PRE_CHROOT; then # PHASE ONE - PREPARE INSTALL FILESYSTEM, INSTALL BASE, PRE-CHROOT
LoadBlock WARN_impending_doom
LoadEFIModules || true
LoadBlock PREFLIGHT_default
LoadBlock FILESYSTEM_gpt_lukspassphrase_ext4_root
FILESYSTEM_PRE_BASEINSTALL # make filesystem
LoadBlock BASEINSTALL_pacstrap
FILESYSTEM_POST_BASEINSTALL # write filesystem configs
FILESYSTEM_PRE_CHROOT # unmount efi boot part
#LoadEFIModules #DEBUG - IMPORTANT TO TEST REMOVAL
Chroot_And_Continue
fi

if $POST_CHROOT; then # PHASE TWO - CHROOTED, CONFIGURE SYSTEM
LoadBlock FILESYSTEM_gpt_lukspassphrase_ext4_root
LoadEFIModules || true
FILESYSTEM_POST_CHROOT # remount efi boot part
LoadBlock LOCALE_default
LoadBlock TIME_ntp
LoadBlock DAEMONS_default
LoadBlock HOSTNAME_default
LoadBlock NETWORK_wired_wireless_minimal
LoadBlock KERNEL_default
LoadBlock RAMDISK_default
LoadBlock BOOTLOADER_efi_gummiboot
#LoadBlock POSTFLIGHT_add_sudo_user 
#LoadBlock POWER_acpi # could be system specific
#LoadBlock AUDIO_alsa_basic
#LoadBlock VIDEO_mesa_basic
#LoadBlock XORG_wacom_fonts
#LoadBlock DESKTOP_xmonad-minimal
#LoadBlock SYSTEM_${SYSTEMTYPE} # other system tweaks for specific hw
#LoadBlock UTILS_${USERNAME}
#LoadBlock HOMESETUP_${USERNAME}
fi

# PHASE THREE - EXITED CHROOT - OPTIONAL UNMOUNT AND REBOOT
#if $POST_INSTALL; then
#Unmount_And_Reboot
#fi

