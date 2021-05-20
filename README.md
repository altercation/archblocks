archblocks
==========

** Minimal archblocks fork **

## EXAMPLE:

`# curl -sfL https://git.io/JsPzg > install.sh; bash install.sh`

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