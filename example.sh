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
REMOTE=https://raw.github.com/altercation/archblocks/newstructure


# eval "$(curl -fsL \"${REMOTE}/lib/functions.sh\")"; # LOAD HELPER FUNCS


# ------------------------------------------------------------------------

DefaultIfUnset () { eval "${1}=\"${!1:-${2}}\""; }
#DefaultIfUnset USERNAME user
#DefaultIfUnset SYSTEMTYPE unknown
DefaultIfUnset HOSTNAME archlinux
DefaultIfUnset USERSHELL /bin/bash
DefaultIfUnset FONT Lat2-Terminus16
DefaultIfUnset LANGUAGE en_US.UTF-8
DefaultIfUnset KEYMAP us
DefaultIfUnset TIMEZONE US/Pacific
DefaultIfUnset MODULES "dm_mod dm_crypt aes_x86_64 ext2 ext4 vfat intel_agp drm i915"
DefaultIfUnset HOOKS "base udev autodetect pata scsi sata usb usbinput consolefont encrypt filesystems fsck"
DefaultIfUnset KERNEL_PARAMS "quiet" # set/used in FILESYSTEM,INIT,BOOTLOADER blocks
DefaultIfUnset DRIVE /dev/sda # this overrides any default value set in FILESYSTEM block
DefaultIfUnset PRIMARY_BOOTLOADER UEFI # UEFI or BIOS
DefaultIfUnset REMOTE https://raw.github.com/altercation/archblocks/master


#set -o errexit

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
_loadblock () { echo "PHASE: $2 - LOADING $1"; FILE="${1/%.sh/}.sh"; [ -f "${DIR/%\//}/${FILE}" ] && URL="file://${FILE}" || URL="${REMOTE/%\//}/blocks/${FILE}"; eval "$(curl -fsL ${URL})"; } 
arch-prep () { if [ ! -e "${POSTSCRIPT}" ] && [ ! -e "${MNT}${POSTSCRIPT}" ]; then [ -z "$@" ] && return 0 || _loadblock "$@" "$FUNCNAME";
elif [ -e "${POSTSCRIPT}" ] && [ "$1:0:10" == "filesystem" ]; then _loadblock "$@" "$FUNCNAME"; else [ -z "$@" ] && return 1 || return 0; fi; }
arch-config () { if [ -e "${POSTSCRIPT}" ]; then [ -z "$@" ] && return 0 || _loadblock "$@" "$FUNCNAME"; else [ -z "$@" ] && return 1 || return 0; fi; }
arch-custom () { if [ -e "${POSTSCRIPT}" ]; then [ -z "$@" ] && return 0 || _loadblock "$@" "$FUNCNAME"; else [ -z "$@" ] && return 1 || return 0; fi; }



# load efivars (or confirm they've loaded already) and set EFI_MODE for later use by bootloader
_load_efi_modules () {
ls -l /sys/firmware/efi/vars/ &>/dev/null && return 1 || true; modprobe efivars || true;
if ls -l /sys/firmware/efi/vars/ >/dev/null; then return 0; else return 1; fi; }
PRIMARY_BOOTLOADER="$(echo "$PRIMARY_BOOTLOADER" | tr [:lower:] [:upper:])";
[ "${PRIMARY_BOOTLOADER#U}" == "EFI" ] && _load_efi_modules && EFI_MODE=true || EFI_MODE=false

# set the preferred font
setfont $FONT

# ------------------------------------------------------------------------


# ANOINT (prep system prior to install; install base)
arch-prep && echo "ANOINT START" || true
arch-prep query/warning
arch-prep filesystem/gpt_luks_passphrase_ext4_root
#arch-prep baseinstall/pacstrap


if arch-prep; then
# makes filesystem (provided by FILESYSTEM block)
_filesystem_pre_baseinstall

# standard pacstrap helper script
pacstrap ${MOUNT_PATH} base base-devel

# write filesystem configs (provided by FILESYSTEM block)
_filesystem_post_baseinstall

# unmount efi boot part (provided by FILESYSTEM block)
_filesystem_pre_chroot

# arch-chroot and proceed with script
_chroot_postscript
else
:
fi



# BASICS (arch-configd in chroot)
arch-config && echo "BASICS START" || true
arch-config filesystem/gpt_luks_passphrase_ext4_root
arch-config time/ntp
arch-config daemons/default
arch-config hostname/default
arch-config network/wired_wireless_minimal
arch-config ramdisk/default
arch-config audio/alsa
arch-config video/intel
arch-config power/acpi
arch-config hardware/lenovo/thinkpad_x220
arch-config kernel/default
arch-config ramdisk/default
arch-config bootloader/efi_gummiboot

# CUSTOMIZE (still in chroot)
arch-custom && echo "CUSTOM START" || true
arch-custom desktop/xmonad
arch-custom apps/audio_arch-config
arch-custom apps/video_arch-config
arch-custom apps/cli_utils

# FINISHED
#reboot
