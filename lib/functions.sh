#!/bin/bash

HR=-----------------------------------------------------------------------
MOUNT_PATH=/mnt # can override in actual install script

SetValue () {
valuename="$1" newvalue="$2" filepath="$3";
sed -i "s+^#\?\(${valuename}\)=.*$+\1=${newvalue}+" "${filepath}";
}

CommentOutValue () {
valuename="$1" filepath="$2";
sed -i "s/^\(${valuename}.*\)$/#\1/" "${filepath}";
}

UncommentValue () {
valuename="$1" filepath="$2";
sed -i "s/^#\(${valuename}.*\)$/\1/" "${filepath}";
}

AddToList () {
newitem="$1" listname="$2" filepath="$3";
sed -i "s/\(${listname}.*\)\()\)/\1 ${newitem}\2/" "${filepath}";
}

AnyKey () { read -sn 1 -p "$@"; }

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
modprobe efivars || true
if ls -l /sys/firmware/efi/vars/ >/dev/null; then
echo "Kernel EFI module loaded, continuing..."
else
echo "Failed to boot into EFI mode, exiting..."
exit 1
fi
}

LoadBlock () {
. /dev/stdin <<< "$(curl -fs ${RAW_REPO_URL/%\//}/blocks/${1}.sh)"
}

CHROOT_CONTINUE () {
# copy entire script and continue execution of it post chroot
POSTCHROOT_FILEPATH="/postchroot.sh"
cat > "${MOUNT_PATH/%\//}/${POSTCHROOT_FILEPATH}" <<CHROOT_SCRIPT_PREFIX
#!/bin/bash
INCHROOT=true
CHROOT_SCRIPT_PREFIX
cat "$0" >> "${MOUNT_PATH/%\//}/${POSTCHROOT_FILEPATH}"
arch-chroot ${MOUNT_PATH} <<EOF
[ -n $DEBUG ] && bash -x /postchroot.sh || sh /postchroot.sh
EOF
}

UNMOUNT_REBOOT () {
unmount "${MOUNT_PATH/%\//}/${BOOT_PARTITION}"
unmount "${MOUNT_PATH}"
reboot
}

# ------------------------------------------------------------------------
# STUB FUNCTIONS - overridden in their eponymous blocks
# ------------------------------------------------------------------------

FILESYSTEM_PRE_BASEINSTALL () { :; }
FILESYSTEM_POST_BASEINSTALL () { :; }
FILESYSTEM_PRE_CHROOT () { :; }
FILESYSTEM_POST_CHROOT () { :; }
