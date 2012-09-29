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
_setvalue () { valuename="$1" newvalue="$2" filepath="$3"; sed -i "s+^#\?\(${valuename}\)=.*$+\1=${newvalue}+" "${filepath}"; }
_commentoutvalue () { valuename="$1" filepath="$2"; sed -i "s/^\(${valuename}.*\)$/#\1/" "${filepath}"; }
_uncommentvalue () { valuename="$1" filepath="$2"; sed -i "s/^#\(${valuename}.*\)$/\1/" "${filepath}"; }
_addtolist () { newitem="$1" listname="$2" filepath="$3"; sed -i "s/\(${listname}.*\)\()\)/\1 ${newitem}\2/" "${filepath}"; }
_anykey () { echo -e "\n$@"; read -sn 1 -p "Any key to continue..."; echo; }
_installpkg () { pacman -S --noconfirm "$@"; }
_installaur () {
if command -v packer >/dev/null 2>&1; then packer -S --noconfirm "$@";
else pkg=packer; orig="$(pwd)"; mkdir -p /tmp/${pkg}; cd /tmp/${pkg};
for req in wget git jshon; do command -v $req >/dev/null 2>&1 || InstallPackage $req; done
wget "https://aur.archlinux.org/packages/${pkg}/${pkg}.tar.gz"; tar -xzvf ${pkg}.tar.gz; cd ${pkg};
makepkg --asroot -si --noconfirm; cd "$orig"; rm -rf /tmp/${pkg}; packer -S --noconfirm "$@"; fi; }
_chroot_postscript () { cp "${PRESCRIPT}" "${MNT}${POSTSCRIPT}"; chmod a+x "${MNT}${POSTSCRIPT}"; arch-chroot "${MNT}" "${POSTSCRIPT}"; }
_loadblock () { FILE="${1/%.sh/}.sh"; [ -f "${DIR/%\//}/${FILE}" ] && URL="file://${FILE}" || URL="${REMOTE/%\//}/blocks/${FILE}"; eval "$(curl -fsL ${URL})"; } 
anoint () { if [ ! -e "${POSTSCRIPT}" ] || [ ! -e "${MNT}${POSTSCRIPT}" ]; then [ -z "$@" ] && return 0 || _loadblock "$@";
elif [ -e "${POSTSCRIPT}" ] && [ "$1:0:10" == "filesystem" ]; then _loadblock "$@"; fi; }
basics () { if [ -e "${POSTSCRIPT}" ]; then [ -z "$@" ] && return 0 || _loadblock "$@"; fi; }
custom () { if [ -e "${POSTSCRIPT}" ]; then [ -z "$@" ] && return 0 || _loadblock "$@"; fi; }



# load efivars (or confirm they've loaded already) and set EFIMODE for later use by bootloader
_load_efi_modules () {
ls -l /sys/firmware/efi/vars/ &>/dev/null && return 1 || true; modprobe efivars || true;
if ls -l /sys/firmware/efi/vars/ >/dev/null; then return 0; else return 1; fi; }
PRIMARY_BOOTLOADER="$(echo "$PRIMARY_BOOTLOADER" | tr [:lower:] [:upper:])";
[ "${PRIMARY_BOOTLOADER#U}" == "EFI" ] && _load_efi_modules && EFIMODE=true || EFIMODE=false

# set the preferred font
setfont $FONT

# ------------------------------------------------------------------------


# ANOINT (prep system prior to install; install base)
anoint && echo "ANOINT START"
anoint query/warning
anoint filesystem/gpt_luks_passphrase_ext4_root
anoint baseinstall/pacstrap

# BASICS (configured in chroot)
basics && echo "BASICS START"
basics time/ntp
basics daemons/default
basics hostname/default
basics network/wired_wireless_minimal
basics ramdisk/default
basics audio/alsa
basics video/intel
basics power/acpi
basics hardware/lenovo/thinkpad_x220
basics kernel/default
basics ramdisk/default
basics bootloader/efi/gummiboot

# CUSTOMIZE (still in chroot)
custom && echo "CUSTOM START"
custom desktop/xmonad
custom apps/audio_basics
custom apps/video_basics
custom apps/cli_utils

# FINISHED
#reboot
