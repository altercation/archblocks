archblocks
==========

** Minimal archblocks fork **

## EXAMPLE:

Boot Arch install media (in the example config I expect an EFI boot, but it's trivial to make this work for non EFI):
    # curl -sfL https://git.io/JsPzg > install.sh; bash install.sh


A config/install script (the only script you need to manually execute) looks like this (actual script I use to install Arch on a Thinkpad x220):

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
    HOOKS="base udev autodetect pata scsi sata usb usbinput consolefont encrypt filesystems fsck"
    KERNEL_PARAMS="quiet" # set/used in FILESYSTEM,INIT,BOOTLOADER blocks (this gets added to)
    INSTALL_DRIVE=/dev/sda # this overrides any default value set in FILESYSTEM block
    
    # BLOCKS -----------------------------------------------------------------
    TIME=common/time_ntp_utc
    FILESYSTEM=filesystem/gpt_luks_passphrase_ext4
    BOOTLOADER=bootloader/efi_gummiboot
    NETWORK=network/wired_wireless_minimal
    AUDIO=common/audio_alsa
    POWER=common/power_acpi
    XORG=xorg/xorg_wacom_fonts
    VIDEO=xorg/video_mesa_default
    DESKTOP=xorg/desktop_xmonad_minimal
    HARDWARE=hardware/laptop/lenovo_thinkpad_x220
    APPSETS="appsets/cli_utils appsets/edu_utils appsets/vim_core appsets/mutt_core appsets/git_default appsets/server_utils"
    PACKAGES="git"
    AURPACKAGES=
    
    # EXECUTE ----------------------------------------------------------------
    . <(curl -fsL "${REMOTE}/blocks/_lib/helpers.sh"); _loadblock "_lib/core"

The blocks subdirectory (the only subdirectory used) contains blocks of simple bash script and looks something like this (note the variants in items like NETWORK... I am working on alternates for FILESYSTEM and BOOTLOADER as well, but the principle should be clear)::

    ├── blocks
    │   ├── _lib
    │   │   ├── core.sh <---------------------------- 2. this is the main script,
    │   │   │                                            no need to customize unless
    │   │   │                                            you want to.
    │   │   └── helpers.sh <------------------------- 3. helper function library
    │   │
    │   ├── appsets
    │   │   ├── aurhelper_aura.sh
    │   │   └── server_utils.sh
    │   │
    │   ├── bootloader
    │   │   ├── bios_grub2.sh
    │   │   └── efi_gummiboot.sh
    │   │
    │   ├── common
    │   │   ├── audio_alsa.sh
    │   │   ├── host_default.sh
    │   │   ├── init_systemd.sh
    │   │   ├── install_pacstrap.sh
    │   │   ├── locale_default.sh
    │   │   ├── postflight_rootpass.sh
    │   │   ├── postflight_sudouser.sh
    │   │   ├── power_acpi.sh
    │   │   ├── ramdisk_default.sh
    │   │   └── time_ntp_utc.sh
    │   │
    │   ├── filesystem
    │   │   ├── gpt_luks_passphrase_ext4.sh
    │   │   └── mbr_default.sh
    │   │
    │   ├── hardware
    │   │   ├── desktop
    │   │   ├── laptop
    │   │   │   └── lenovo_thinkpad_x220.sh <-------- 4. custom, per-hardware tweaks
    │   │   ├── peripheral
    │   │   └── server
    │   │
    │   ├── init
    │   │   └── systemd_pure.sh
    │   │
    │   ├── network
    │   │   ├── wired_wireless_default.sh
    │   │   └── wired_wireless_minimal.sh
    │   │
    │   └── xorg
    │       ├── desktop_xmonad_minimal.sh
    │       ├── video_mesa_default.sh
    │       ├── xorg_default.sh
    │       └── xorg_wacom_fonts.sh
    │
    └── example.sh <--------------------------------- 1. this is the initial installer

# TO DO
- [x] Remove old packages
- [ ] Make installers for matebooks
- [ ] Add yay
- [ ] Silent boot
- [ ] Simplify code
- [ ] Ucode
- [ ] Fix journalist errors