#!/bin/bash
# ------------------------------------------------------------------------
# archblocks - modular Arch Linux install script
# ------------------------------------------------------------------------
# es@ethanschoonover.com @ethanschoonover https://github.com/altercation
# http://github.com/altercation/archblocks

# INSTRUCTIONS -----------------------------------------------------------
# boot into Arch Install media and run (for this script only):
# curl -sfL https://raw.github.com/altercation/archblocks/master/install_tau.sh" > install.sh; sh install.sh


# CONFIG -----------------------------------------------------------------

PRIMARY_BOOTLOADER=EFI
HOSTNAME=tau
HARDWARE=thinkpad_x220
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
REMOTE=https://raw.github.com/altercation/archblocks/newstructure #e.g. file://.

# CONFIG
TIMESET=NTP
FILESYSTEM=gpt_luks_passphrase_ext4_root
BOOTLOADER=efi_gummiboot
NETWORK=wired_wireless_minimal
#DAEMONS=default
#HOSTNAME=default
#RAMDISK=default
AUDIO=alsa
VIDEO=intel
POWER=acpi
#KERNEL=default #unneeded?
POSTFLIGHT="sudo_default create_user"
DESKTOP=xmonad_minimal
APPSETS="cli_utils edu_utils vim_core mutt_core"
BACKPAC=













# eval "$(curl -fsL \"${REMOTE}/lib/functions.sh\")"; # LOAD HELPER FUNCS
# EVERYTHING BELOW THIS LINE LOADED BY ABOVE COMMAND
# ------------------------------------------------------------------------

_default () { eval "${1}=\"${!1:-${2}}\""; } # assign value only if unset
#_default USERNAME user
#_default SYSTEMTYPE unknown
_default HOSTNAME archlinux
_default USERSHELL /bin/bash
_default FONT Lat2-Terminus16
_default LANGUAGE en_US.UTF-8
_default KEYMAP us
_default TIMEZONE US/Pacific
_default MODULES "dm_mod dm_crypt aes_x86_64 ext2 ext4 vfat intel_agp drm i915"
_default HOOKS "base udev autodetect pata scsi sata usb usbinput consolefont encrypt filesystems fsck"
_default KERNEL_PARAMS "quiet" # set/used in FILESYSTEM,INIT,BOOTLOADER blocks
_default DRIVE /dev/sda # this overrides any default value set in FILESYSTEM block
_default PRIMARY_BOOTLOADER UEFI # UEFI or BIOS
_default REMOTE https://raw.github.com/altercation/archblocks/master







set -o errexit

# CLEAN THIS UP
# PREFLIGHT
# check if initial (main) install script has been properly saved to local file
[ ! -f "${0}" ] && echo "Don't run this directly from curl. Save to file first." && exit
# rm -rf "${TMP}"; mkdir -p "${TMP}"; cp "${0}" "${PRESCRIPT}";
MNT=/mnt; TMP=/tmp/archblocks; POSTSCRIPT="/post-chroot.sh"
DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PRESCRIPT="${DIR/%\//}/$(basename ${0})"; # normalize prescript to full script path
#PRESCRIPT="${0}"
DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

_setvalue () { valuename="$1" newvalue="$2" filepath="$3"; sed -i "s+^#\?\(${valuename}\)=.*$+\1=${newvalue}+" "${filepath}"; }
_commentoutvalue () { valuename="$1" filepath="$2"; sed -i "s/^\(${valuename}.*\)$/#\1/" "${filepath}"; }
_uncommentvalue () { valuename="$1" filepath="$2"; sed -i "s/^#\(${valuename}.*\)$/\1/" "${filepath}"; }
_addtolist () { newitem="$1" listname="$2" filepath="$3"; sed -i "s/\(${listname}.*\)\()\)/\1 ${newitem}\2/" "${filepath}"; }
_anykey () { echo -e "\n$@"; read -sn 1 -p "Any key to continue..."; echo; }
_installpkg () { pacman -S --noconfirm "$@"; }
_installaur () {
if command -v packer >/dev/null 2>&1; then packer -S --noconfirm "$@";
else pkg=packer; orig="$(pwd)"; mkdir -p /tmp/${pkg}; cd /tmp/${pkg};
for req in wget git jshon; do command -v $req >/dev/null 2>&1 || _installpkg $req; done
wget "https://aur.archlinux.org/packages/${pkg}/${pkg}.tar.gz"; tar -xzvf ${pkg}.tar.gz; cd ${pkg};
makepkg --asroot -si --noconfirm; cd "$orig"; rm -rf /tmp/${pkg}; packer -S --noconfirm "$@"; fi; }
_chroot_postscript () { cp "${PRESCRIPT}" "${MNT}${POSTSCRIPT}"; chmod a+x "${MNT}${POSTSCRIPT}"; arch-chroot "${MNT}" "${POSTSCRIPT}"; }
_warn () { _anykey "WARNING: This script will permanently erase the install drive."; }

_filesystem_pre_baseinstall () { :; }
_filesystem_post_baseinstall () { :; }
_filesystem_pre_chroot () { :; }
_filesystem_post_chroot () { :; }


#TODO: make loadblock a loop over each argument passed to it
_loadblock () { echo "PHASE: $2 - LOADING $1"; FILE="${1/%.sh/}.sh"; [ -f "${DIR/%\//}/${FILE}" ] && URL="file://${FILE}" || URL="${REMOTE/%\//}/blocks/${FILE}"; eval "$(curl -fsL ${URL})"; } 


# should add a first-run (first call to function for each phase) check and initialization phase
#arch-prep () { if [ ! -e "${POSTSCRIPT}" ] && [ ! -e "${MNT}${POSTSCRIPT}" ]; then [ -z "$@" ] && return 0 || _loadblock "$@" "$FUNCNAME";
#elif [ -e "${POSTSCRIPT}" ] && [ "$1:0:10" == "filesystem" ]; then _loadblock "$@" "$FUNCNAME"; else [ -z "$@" ] && return 1 || return 0; fi; }
#arch-config () { if [ -e "${POSTSCRIPT}" ]; then [ -z "$@" ] && return 0 || _loadblock "$@" "$FUNCNAME"; else [ -z "$@" ] && return 1 || return 0; fi; }
#arch-custom () { if [ -e "${POSTSCRIPT}" ]; then [ -z "$@" ] && return 0 || _loadblock "$@" "$FUNCNAME"; else [ -z "$@" ] && return 1 || return 0; fi; }

#archprepX () {
#_anykey "IN ARCH PREP - check for ${MNT} and ${POSTSCRIPT}"
#if [ ! -e "${POSTSCRIPT}" ] && [ ! -e "${MNT}${POSTSCRIPT}" ]; then
#_anykey "EXEC ARCH PREP"
#setfont $FONT
#$EFI_MODE && _load_efi_modules
#_warn
#_loadblock "filesystem/${FILESYSTEM}"
#_filesystem_pre_baseinstall
#pacstrap ${MOUNT_PATH} base base-devel
#_filesystem_post_baseinstall
#_filesystem_pre_chroot
#_chroot_postscript
#else
#_anykey "SKIP ARCH PREP"
#fi
#}
archprep () {
echo ">>>>>>>>>>>>>>>> 1"
_chroot_postscript
}

archconfigX () {
if [ -e "${POSTSCRIPT}" ]; then
setfont $FONT
$EFI_MODE && _load_efi_modules
_loadblock filesystem/gpt_luks_passphrase_ext4_root
_filesystem_post_chroot
_loadblock time/${TIME}

# HOSTNAME
echo ${HOSTNAME} > /etc/hostname; sed -i "s/localhost\.localdomain/${HOSTNAME}/g" /etc/hosts

# TIME
ln -s /usr/share/zoneinfo/${TIMEZONE} /etc/localtime; echo ${TIMEZONE} >> /etc/timezone
hwclock --systohc --utc # set hardware clock
_installpkg ntp
sed -i "/^DAEMONS/ s/hwclock /!hwclock @ntpd /" /etc/rc.conf

# DAEMONS
# INIT/SYSTEMD

_loadblock network/${NETWORK}
_loadblock audio/${AUDIO}
_loadblock video/${VIDEO}
_loadblock power/${POWER}
_loadblock kernel/${KERNEL}

# RAMDISK
# set default values if not set from variables in the config file
MODULES="${MODULES:-}"
HOOKS="${HOOKS:-base udev autodetect pata scsi sata filesystems usbinput fsck}"
cp /etc/mkinitcpio.conf /etc/mkinitcpio.orig
sed -i "s/^MODULES.*$/MODULES=\"${MODULES}\"/" /etc/mkinitcpio.conf
sed -i "s/^HOOKS.*$/HOOKS=\"${HOOKS}\"/" /etc/mkinitcpio.conf
mkinitcpio -p linux

_loadblock bootloader/efi_gummiboot
fi
}
archconfig () {
if [ -e "${POSTSCRIPT}" ]; then
echo ">>>>>>>>>>>>>>>> 2"
fi
}



# load efivars (or confirm they've loaded already) and set EFI_MODE for later use by bootloader
_load_efi_modules () {
ls -l /sys/firmware/efi/vars/ &>/dev/null && return 1 || true; modprobe efivars || true;
if ls -l /sys/firmware/efi/vars/ >/dev/null; then return 0; else return 1; fi; }
#PRIMARY_BOOTLOADER="$(echo "$PRIMARY_BOOTLOADER" | tr [:lower:] [:upper:])";
#[ "${PRIMARY_BOOTLOADER#U}" == "EFI" ] && _load_efi_modules && EFI_MODE=true || EFI_MODE=false


# ------------------------------------------------------------------------

archprep
archconfig
#archcustomize
