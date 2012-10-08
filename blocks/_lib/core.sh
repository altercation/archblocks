#!/bin/bash
# ------------------------------------------------------------------------
# archblocks - modular Arch Linux install script
# ------------------------------------------------------------------------
# blocks/lib/core.sh - main installer execution sequence

# PREFLIGHT --------------------------------------------------------------

# buckle up
#set -o errexit

# check if we're in an IO redirect or incorrectly sourced script
[ ! -f "${0}" ] && echo "Don't run this directly from curl. Save to file first." && exit

# set mount point, temp directory, script values
MNT=/mnt; TMP=/tmp/archblocks; POSTSCRIPT="/post-chroot.sh"

# get chroot status
[ -e "${POSTSCRIPT}" ] && INCHROOT=true || INCHROOT=false

# DEFAULT REPOSITORY URL -------------------------------------------------
# (probably not useful here if initialization script has already used it,
# but retained here for reference)

_defaultvalue REMOTE https://raw.github.com/altercation/archblocks/master

# DEFAULT CONFIG VALUES --------------------------------------------------

_defaultvalue HOSTNAME archlinux
_defaultvalue USERSHELL /bin/bash
_defaultvalue FONT Lat2-Terminus16
_defaultvalue FONT_MAP 8859-1_to_uni
_defaultvalue LANGUAGE en_US.UTF-8
_defaultvalue KEYMAP us
_defaultvalue TIMEZONE US/Pacific
_defaultvalue MODULES ""
_defaultvalue HOOKS "base udev autodetect pata scsi sata filesystems usbinput fsck"
_defaultvalue KERNEL_PARAMS "quiet" # set/used in FILESYSTEM,INIT,BOOTLOADER blocks
_defaultvalue AURHELPER packer
_defaultvalue INSTALL_DRIVE /dev/sda # this overrides any default value set in FILESYSTEM block

#TODO: REMOVE THIS #_defaultvalue PRIMARY_BOOTLOADER UEFI # UEFI or BIOS (case insensitive)

# CONFIG VALUES WHICH REMAIN UNDEFAULTED ---------------------------------
# for reference - these remain unset if not already declared
# USERNAME, SYSTEMTYPE

# BLOCKS DEFAULTS --------------------------------------------------------

_defaultvalue INSTALL common/install_pacstrap
_defaultvalue HARDWARE ""
_defaultvalue TIME common/time_ntp_utc # or, e.g. time_ntp_localtime
_defaultvalue SETLOCALE common/locale_default
_defaultvalue HOST common/host_default
_defaultvalue FILESYSTEM filesystem/mbr_ext4
_defaultvalue DRIVE /dev/sda # this overrides any default value set in FILESYSTEM block
_defaultvalue RAMDISK common/ramdisk_default
_defaultvalue BOOTLOADER bootloader/bios_grub
_defaultvalue NETWORK network/wired_wireless_default
#_defaultvalue INIT init/systemd_pure
#_defaultvalue INIT=init/systemd_coexist
#_defaultvalue INIT=init/sysvinit_default
_defaultvalue XORG ""
_defaultvalue AUDIO ""
_defaultvalue VIDEO ""
_defaultvalue POWER ""
_defaultvalue DESKTOP ""
_defaultvalue POSTFLIGHT "common/postflight_rootpass common/postflight_sudouser"
_defaultvalue APPSETS ""
_defaultvalue PACKAGES "git"
_defaultvalue AURPACKAGES "git"

# ARCH PREP & SYSTEM INSTALL (PRE CHROOT) --------------------------------
if ! $INCHROOT; then
_initialwarning                 # WARN USER OF IMPENDING DOOM
_setfont                        # SET FONT FOR PLEASANT INSTALL EXPERIENCE
_load_efi_modules || true       # ATTEMPT TO LOAD EFIVARS, EVEN IF NOT USING EFI (REQUIRED)
_loadblock "${FILESYSTEM}"      # LOAD FILESYSTEM (FUNCTIONS AND VARIABLE DECLARATION ONLY)
_filesystem_pre_baseinstall     # FILESYSTEM CREATION AND CONFIG
_loadblock "${INSTALL}"         # INSTALL ARCH
_filesystem_post_baseinstall    # WRITE FSTAB/CRYPTTAB AND ANY OTHER POST INTALL FILESYSTEM CONFIG
_filesystem_pre_chroot          # PROBABLY UNMOUNT OF BOOT IF INSTALLING UEFI MODE
_chroot_postscript              # CHROOT AND CONTINUE EXECUTION
fi

# ARCH CONFIG (POST CHROOT) ----------------------------------------------
if $INCHROOT; then
umount /tmp; mount -t tmpfs tmp "$1/tmp" -o mode=1777,strictatime,nodev,nosuid,size=150M
_loadblock "${FILESYSTEM}"      # LOAD FILESYSTEM FUNCTIONS
pacman -Sy
_filesystem_post_chroot         # FILESYSTEM POST-CHROOT CONFIGURATION
#_loadblock "${INIT}"       	# INIT
_loadblock "${SETLOCALE}"       # SET LOCALE
_loadblock "${TIME}"            # TIME
_loadblock "${HOST}"            # HOSTNAME
                                # DAEMONS
                                # INIT/SYSTEMD
_loadblock "${NETWORK}"         # NETWORKING
_loadblock "${AUDIO}"           # AUDIO
_loadblock "${VIDEO}"           # VIDEO
_loadblock "${POWER}"           # POWER
#_loadblock "${KERNEL}"         # KERNEL
_loadblock "${RAMDISK}"         # RAMDISK
_loadblock "${BOOTLOADER}"      # BOOTLOADER
_loadblock "${XORG}"            # XORG
_loadblock "${DESKTOP}"         # DESKTOP/WM/ETC
_loadblock "${POSTFLIGHT}"      # COMMON POST INSTALL ROUTINES
_loadblock "${HARDWARE}"        # COMMON POST INSTALL ROUTINES
_loadblock "${APPSETS}"         # COMMON APPLICATION/UTILITY SETS
_installpkg ${PACKAGES}
_installaur ${AURPACKAGES}
[ -n "${MR_BOOTSTRAP}" ] && _loadblock "common/mr_bootstrap"
fi

