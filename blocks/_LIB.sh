# PREFLIGHT
# check if initial (main) install script has been properly saved to local file
[ ! -f "${0}" ] && echo "Don't run this directly from curl. Save to file first." && exit
# rm -rf "${TMP}"; mkdir -p "${TMP}"; cp "${0}" "${PRESCRIPT}";

#set -o errexit
MNT=/mnt; TMP=/tmp/archblocks; POSTSCRIPT="/post-chroot.sh"
DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PRESCRIPT="${DIR/%\//}/$(basename ${0})"; # normalize prescript to full script path
#PRESCRIPT="${0}"
DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# DETECT CHROOT
[ -e "${POSTSCRIPT}" ] && POST_CHROOT=true || POST_CHROOT=false;
$POST_CHROOT && PRE_CHROOT=false || PRE_CHROOT=true; POST_INSTALL=$PRE_CHROOT

LoadFailCheck () { :; }

LoadBlock () {
# source locally if available, based on current script path, otherwise from remote
FILE="${1/%.sh/}.sh"; [ -f "${DIR/%\//}/${FILE}" ] && URL="file://${FILE}" || URL="${REMOTE/%\//}/blocks/${FILE}"; eval "$(curl -fsL ${URL})"; }

LoadBlockAtomic () { FILE="${1/%.sh/}.sh"; [ -f "${DIR/%\//}/${FILE}" ] && URL="file://${FILE}" || URL="${REMOTE/%\//}/blocks/${FILE}"; curl -fsL ${URL} > "${TMP}/blocks/${FILE}" && eval "${TMP}/blocks/${FILE}" || return 1; }

SetValue () { valuename="$1" newvalue="$2" filepath="$3"; sed -i "s+^#\?\(${valuename}\)=.*$+\1=${newvalue}+" "${filepath}"; }

CommentOutValue () { valuename="$1" filepath="$2"; sed -i "s/^\(${valuename}.*\)$/#\1/" "${filepath}"; }

UncommentValue () { valuename="$1" filepath="$2"; sed -i "s/^#\(${valuename}.*\)$/\1/" "${filepath}"; }

AddToList () { newitem="$1" listname="$2" filepath="$3"; sed -i "s/\(${listname}.*\)\()\)/\1 ${newitem}\2/" "${filepath}"; }

AnyKey () { echo -e "\n$@"; read -sn 1 -p "Any key to continue..."; echo; }

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

ConfirmRead () {
unset _match; echo; while [ -z "${_match}" ]; do read -s -p "Enter $1: " p1; echo; read -s -p "Confirm $1: " p2
[ "${p1}" == "${p2}" ] && _match=true || echo "$1 does not match"; done; echo "${p1}"
}

Unmount_And_Reboot () {
#TODO
:
}

LoadEFIModules () {
AnyKey "CONFIRMING..."
ls -l /sys/firmware/efi/vars/ &>/dev/null && return 1 || true
modprobe efivars || true
if ls -l /sys/firmware/efi/vars/ >/dev/null; then
	echo "Kernel EFI module loaded, continuing..."
	return 0
else
	echo "\nFailed to boot into EFI mode...\nwill install EFI default bootloader."
	echo "\nRecommend installing proper EFI bootloader via efibootmgr after reboot."
	return 1
fi
}

Chroot_And_Continue () {
cp "${PRESCRIPT}" "${MNT}${POSTSCRIPT}"; chmod a+x "${MNT}${POSTSCRIPT}"
arch-chroot "${MNT}" "${POSTSCRIPT}"
}

