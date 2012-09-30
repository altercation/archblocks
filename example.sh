#!/bin/bash
# ------------------------------------------------------------------------
# archblocks - modular Arch Linux install script
# ------------------------------------------------------------------------
# es@ethanschoonover.com @ethanschoonover
# http://github.com/altercation/archblocks

# INSTRUCTIONS -----------------------------------------------------------

# boot into Arch Install media and run (for this script only):
#
# curl -sfL https://raw.github.com/altercation/archblocks/master/install_tau.sh" > install.sh; sh install.sh

# SCRIPT PREP ------------------------------------------------------------

REMOTE=https://raw.github.com/altercation/archblocks/newstructure #e.g. file://.

# CONFIG -----------------------------------------------------------------

HOSTNAME=tau
USERNAME=es
USERSHELL=/bin/bash
FONT=Lat2-Terminus16
LANGUAGE=en_US.UTF-8
KEYMAP=us
TIMEZONE=US/Pacific
MODULES="dm_mod dm_crypt aes_x86_64 ext2 ext4 vfat intel_agp drm i915"
HOOKS="base udev autodetect pata scsi sata usb usbinput consolefont encrypt filesystems fsck"
KERNEL_PARAMS="quiet" # set/used in FILESYSTEM,INIT,BOOTLOADER blocks (this gets added to)
#AURHELPER=packer # default is packer, any alternate must have pacman syntax parity
#PRIMARY_BOOTLOADER=EFI

# BLOCKS -----------------------------------------------------------------

HARDWARE=thinkpad_x220
TIME=ntp_utc # ntp_localtime
FILESYSTEM=gpt_luks_passphrase_ext4_root
DRIVE=/dev/sda # this overrides any default value set in FILESYSTEM block
BOOTLOADER=efi_gummiboot
NETWORK=wired_wireless_minimal
AUDIO=alsa
VIDEO=intel
POWER=acpi
DESKTOP=xmonad_minimal
APPSETS="cli_utils edu_utils vim_core mutt_core"
POSTFLIGHT="sudo_default create_user"

# following a block or a standard backpac file? probably just file
BACKPAC=

# EXECUTE ----------------------------------------------------------------

#eval "$(curl -fsL \"${REMOTE}/blocks/lib/helpers.sh\")"
. <<< "$(curl -fsL \"${REMOTE}/blocks/lib/helpers.sh\")"
_loadblock lib/core
