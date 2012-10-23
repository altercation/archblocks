#!/bin/bash
# ------------------------------------------------------------------------
# archblocks - minimal, modular, manual Arch Linux install script
# ------------------------------------------------------------------------
# es@ethanschoonover.com @ethanschoonover http://github.com/altercation/archblocks

# INSTRUCTIONS -----------------------------------------------------------
# boot into Arch Install media and run (for this script only):
#
# curl https://raw.github.com/altercation/archblocks/master/sample_installer.sh" > install.sh
#     (...manually review the code! look at the blocks in the repo, then...)
# bash install.sh

# RESPOSITORY ------------------------------------------------------------
REMOTE=https://raw.github.com/altercation/archblocks/dev

# CONFIG -----------------------------------------------------------------

HOSTNAME=tau
USERNAME=es
USERSHELL=/bin/bash
FONT=Lat2-Terminus16
FONT_MAP=8859-1_to_uni
LANGUAGE=en_US.UTF-8
KEYMAP=us
TIMEZONE=US/Pacific
MODULES="dm_mod dm_crypt aes_x86_64 ext2 ext4 vfat intel_agp drm i915"
HOOKS="base udev autodetect pata scsi sata usb usbinput consolefont encrypt filesystems fsck shutdown"
# KERNEL_PARAMS is used in FILESYSTEM, INIT, BOOTLOADER blocks (gets added to)
# No longer require these i915 tweaks
#KERNEL_PARAMS="quiet i915.modeset=1 i915.i915_enable_rc6=1 i915.i915_enable_fbc=1 i915.lvds_downclock=1"
KERNEL_PARAMS=""

# DOTFILES / HOME SETUP --------------------------------------------------
# mr (available in AUR) allows you to setup your home dir using dvcs such
# as git, hg, svn and execute shell scripts automatically. 
# list a url to use as a mr config file and archblocks core install will
# su to the new user's (USERNAME above) home and bootstrap using it.
# mr will be installed if this variable is set.
MR_BOOTSTRAP=https://raw.github.com/altercation/es-etc/master/vcs/.mrconfig

# BLOCKS -----------------------------------------------------------------
TIME=common/time_chrony_utc
FILESYSTEM=filesystem/gpt_luks_passphrase_ext4
BOOTLOADER=bootloader/efi_gummiboot
NETWORK=network/wired_wireless_default
AUDIO=common/audio_alsa
POWER=common/power_acpi
SENSORS=common/sensors_default
XORG="xorg/xorg_default xorg/xorg_fonts_infinality xorg/xorg_wacom xorg/xorg_synaptics xorg/mesa_dri"
VIDEO=video/video_intel
SOUND=sound/sound_intel
DESKTOP=xorg/desktop_xmonad_minimal
HARDWARE=hardware/laptop/lenovo_thinkpad_x220
APPSETS="appsets/hw_utils appsets/cli_hardcore appsets/vim_basics appsets/mutt_basics appsets/git_basics appsets/server_utils appsets/chromium_basics"

# EXTRA PACKAGES ---------------------------------------------------------
# if you don't want to create a new block, you can specify extra packages
# from official repos or AUR here (simple space separated list of packages)
PACKAGES="git rxvt-unicode xterm"
AURPACKAGES="termite-git"

# EXECUTE ----------------------------------------------------------------
. <(curl -fsL "${REMOTE}/blocks/_lib/helpers.sh"); _loadblock "_lib/core"

