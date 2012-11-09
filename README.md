archblocks
==========

ArchBlocks - a minimal, modular, manual install framework

## WHAT:

ArchBlocks is a very lightweight framework for creating quick, modular, *non-interactive* Arch Linux install scripts tailored to specific systems. It is accessible via a single quick curl downloadable script (from, for example, github).

## WHERE:

Example repo at https://github.com/altercation/archblocks
Arch BBS: https://bbs.archlinux.org/viewtopic.php?id=149597

## EXAMPLE:

Boot Arch install media (in the example config I expect an EFI boot, but it's trivial to make this work for non EFI):

    # curl -sfL https://raw.github.com/altercation/archblocks/master/install_tau.sh" > install.sh; bash install.sh

or in short url form:

    # curl -sfL http://git.io/rQx7Xw > install.sh; bash install.sh

(this then sources the blocks of code remotely and configures the system based on the specific blocks called and variables set in in; see below)

## WHAT IT ISN'T:

ArchBlocks is not an interactive general purpose script that asks you what you'd like. You *must* customize it (or its blocks) as much as any other install script. ArchBlocks simply makes this process easier to maintain as a single project that is applicable for multiple systems.

## WHY:

Many somewhat experienced Arch users end up building lightweight install scripts to set up their systems. I've been wanting to modularize my own install scripts such that multiple, different system types (laptop/server/desktop/headless) can reuse most of the common elements easily and swap out blocks of code as needed.

AND YET it's easy to make something like this far too complex. To paraphrase the Ruby community: Arch is Simple so Our Utilities Are Simple. ArchBlocks kickstarts off a *single* "configuration" script and loads blocks from a *single* directory (remote or local, doesn't matter).

(I've previously written extensive additions to AIF before it was frozen in carbonite, and that experience convinced me of the value of a non-interactive, simple install script based approach).

## NO REALLY, WHY NOT JUST MONOLITHIC INSTALL SCRIPTS, WHY MODULAR:

There is install code that may be impacted by changes to Arch, or I sometimes want to improve the way I handle some part of the installation. This may impact multiple systems. Rather than update and maintain five different manual install scripts, modular is better approach. A simple example is the various `NETWORK_*` blocks. I can keep using the default network setup method in most of my scripts and use a light weight / minimal network install method by just swapping out a block. This minimal install script can be revised and all systems that I install with it in future will make use of the revision.

## BUT INSTALLING ARCH IS EASY

It is. It's mostly the filesystem and bootloader varieties which create complexity for me. This addresses that.

Another benefit of this modular approach is I can include post-flight app installation a per machine basis (my server gets nginx, my laptop gets dwarffortress). All automated.

## DETAILS:

Each system I install gets a single config file (the "tau" script in the example above is a laptop). This script loads a few very lightweight helper functions (maintained in a lib file for reuse across "config" scripts) and then loads blocks from the (surprise) blocks directory (local or remote). These blocks are almost all just simple blocks of bash script. The only exceptions should be very clear from the example: there are a few functions that are very specific to the filesytem configuration that must be sprinkled throughout the code. These functions and their intended sequence in the script are easily identified by name such as FILESYSTEM_PRE_BASEINSTALL (in this case FILESYSTEM_PRE_BASEINSTALL is either a null function or does something as defined in the FILESYSTEM block).

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
    
That's it, really. Nothing fancy. Comprehensible, reusable, modular.

If you want to use something like this, fork away.


