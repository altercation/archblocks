#!/bin/bash
# ------------------------------------------------------------------------
# archblocks - modular Arch Linux install script
# ------------------------------------------------------------------------
# http://github.com/altercation/archblocks
# es@ethanschoonover.com @ethanschoonover https://github.com/altercation

# INSTRUCTIONS -----------------------------------------------------------
# boot into Arch Install media and run:
# sh <(curl -sfL http://git.io/c42guA)

# INSTALLATION TARGET VALUES ---------------------------------------------
HOSTNAME=tau
SYSTEMTYPE=thinkpad_x220
USERNAME=es
USERSHELL=/bin/bash
FONT=Lat2-Terminus16
LANGUAGE=en_US.UTF-8
KEYMAP=us
TIMEZONE=US/Pacific
MODULES="dm_mod dm_crypt aes_x86_64 ext2 ext4 vfat intel_agp drm i915"
HOOKS="usb usbinput consolefont encrypt filesystems"
#DRIVE=/dev/sda (default depends on FILESYSTEM block)

# REMOTE INSTALL SCRIPT REPO ---------------------------------------------
REMOTE=https://raw.github.com/altercation/archblocks/master

# SCRIPT EXECUTION SETTINGS ----------------------------------------------
DEBUG=true
set -o errexit #set -o errexit; set -o nounset # buckle up
MNT=/mnt; TMP=/tmp/archblocks
[ -f "${0}" ] && DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" || DIR="${TMP}"
rm -rf "${TMP}"; mkdir -p "${TMP}"; cp "${0}" "${TMP}" # don't need this if non atomic

# HELPER FUNCTIONS ------------------------------------------------
#LoadBlock () { [ -f "$0" ] && [ -f "${DIR/%\//}/${1/%.sh/}.sh" ] && URL="file://" || URL="${REMOTE/%\//}/"; . /dev/stdin <<< "$(curl -fsL ${URL}${1/%.sh/}.sh)"; }; # LoadBlock _FUNCTIONS

LoadBlock () { FILE="${1/%.sh/}.sh"; [ -f "${DIR/%\//}/${FILE}" ] && URL="file://${FILE}" || URL="${REMOTE/%\//}/blocks/${FILE}"; eval "$(curl -fsL ${URL})"; }

LoadBlockAtomic () { FILE="${1/%.sh/}.sh"; [ -f "${DIR/%\//}/${FILE}" ] && URL="file://${FILE}" || URL="${REMOTE/%\//}/blocks/${FILE}"; curl -fsL ${URL} > "${TMP}/blocks/${FILE}" && eval "${TMP}/blocks/${FILE}" || return 1; }

AnyKey () { read -sn 1 -p "$@"; }

SetValue () { valuename="$1" newvalue="$2" filepath="$3"; sed -i "s+^#\?\(${valuename}\)=.*$+\1=${newvalue}+" "${filepath}"; }

CommentOutValue () { valuename="$1" filepath="$2"; sed -i "s/^\(${valuename}.*\)$/#\1/" "${filepath}"; }

UncommentValue () { valuename="$1" filepath="$2"; sed -i "s/^#\(${valuename}.*\)$/\1/" "${filepath}"; }

AddToList () { newitem="$1" listname="$2" filepath="$3"; sed -i "s/\(${listname}.*\)\()\)/\1 ${newitem}\2/" "${filepath}"; }

InstallPackage () { pacman -S --noconfirm "$@"; }

InstallAURPackage () {
if command -v packer >/dev/null 2>&1; then
	packer -S --noconfirm "$@"
else pkg=packer; orig="$(pwd)"
	mkdir -p /tmp/${pkg}; cd /tmp/${pkg};
	for req in wget git jshon; do
		command -v $req >/dev/null 2>&1 || InstallPackage $req
	done
	wget "https://aur.archlinux.org/packages/${pkg}/${pkg}.tar.gz"
	tar -xzvf ${pkg}.tar.gz; cd ${pkg};
	makepkg --asroot -si --noconfirm
	cd "$orig"; rm -rf /tmp/${pkg}
	packer -S --noconfirm "$@";
fi
}

LoadEFIModules () {
modprobe efivars #|| true
if ls -l /sys/firmware/efi/vars/ >/dev/null; then
echo "Kernel EFI module loaded, continuing..."
else
echo "Failed to boot into EFI mode, exiting..."
exit 1
fi
}


# if we haven't installed yet
if [ ! -d "${MNT/%\//}/etc" ]; then
AnyKey "\nPHASE 1: Filesystem & Base Install --------------------------------"
LoadBlock WARN_impending_doom
LoadBlock PREFLIGHT_default
LoadBlock FILESYSTEM_gpt_luks_ext4_root
FILESYSTEM_PRE_BASEINSTALL # make filesystem
LoadBlock BASEINSTALL_pacstrap
FILESYSTEM_POST_BASEINSTALL # write configs
FILESYSTEM_PRE_CHROOT # unmount efi boot part
modprobe efivars #DEBUG
#CHROOT_CONTINUE
cp /tmp/archblocks/install.sh "${MNT}/post-chroot.sh"; arch-chroot <<< "/post-chroot.sh"
fi

# if we are in chroot
#if [ -n ${INCHROOT:-} ]; then
###if [ -n ${INCHROOT:-} ] && [ ! -d "${MOUNT_PATH/%\//}/etc" ]; then
# load fs again since chroot is new and we need fs variables in bootloader
# todo make pre-bootloader function which generalizes the variable used by
# bootloader. we also need to run the post chroot filesystem function.
if [ ! -d "${MNT/%\//}/etc" ]; then
AnyKey "\nPHASE 2: chroot and system configuration --------------------------"
LoadBlock FILESYSTEM_gpt_luks_ext4_root
modprobe efivars #DEBUG
FILESYSTEM_POST_CHROOT # remount efi boot part
LoadBlock LOCALE_default
LoadBlock TIME_ntp
LoadBlock DAEMONS_default
LoadBlock HOSTNAME_default
LoadBlock NETWORK_wired_wireless_minimal
LoadBlock KERNEL_default
LoadBlock RAMDISK_default
LoadBlock BOOTLOADER_efi_gummiboot
LoadBlock POSTFLIGHT_add_sudo_user 
LoadBlock POWER_acpi # could be system specific
LoadBlock AUDIO_alsa_basic
LoadBlock VIDEO_mesa_basic
#LoadBlock XORG_wacom_fonts
#LoadBlock DESKTOP_xmonad-minimal
#LoadBlock SYSTEM_${SYSTEMTYPE} # other system tweaks for specific hw
#LoadBlock UTILS_${USERNAME}
#LoadBlock HOMESETUP_${USERNAME}
fi

AnyKey "\nPHASE 3: Exit -----------------------------------------------------"
exit

# ready to rock
#echo -e "\nPHASE 2: chroot and system configuration --------------------------"
#AnyKey
#echo "WRAP UP"
#exit
#UNMOUNT_REBOOT
