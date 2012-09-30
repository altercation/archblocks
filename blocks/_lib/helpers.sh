#!/bin/bash
# ------------------------------------------------------------------------
# archblocks - modular Arch Linux install script
# ------------------------------------------------------------------------
# blocks/lib/helpers.sh - common helper functions

# DEFAULTVALUE -----------------------------------------------------------
_defaultvalue ()
{
# Assign value to a variable in the install script only if unset or empty.
#
# usage:
#
# _defaultvalue VARNAME "value if VARNAME is currently unset or empty"
#
eval "${1}=\"${!1:-${2}}\"";
}

# SETVALUE ---------------------------------------------------------------
_setvalue ()
{
# Assign a value to a "standard" bash format variable in a config file
# or script. For example, given a file with path "path/to/file.conf"
# with a variable defined like this:
#
# VARNAME=valuehere
#
# the value can be changed using this function:
#
# _setvalue newvalue VARNAME "path/to/file.conf"
#
valuename="$1" newvalue="$2" filepath="$3";
sed -i "s+^#\?\(${valuename}\)=.*$+\1=${newvalue}+" "${filepath}";
}

# COMMENTOUTVALUE --------------------------------------------------------
_commentoutvalue ()
{
# Comment out a value in "standard" bash format. For example, given a
# file with a variable defined like this:
#
# VARNAME=valuehere
#
# the value can be commented out to look like this:
#
# #VARNAME=valuehere
#
# using this function:
#
# _commentoutvalue VARNAME "path/to/file.conf"
#
valuename="$1" filepath="$2";
sed -i "s/^\(${valuename}.*\)$/#\1/" "${filepath}";
}

# UNCOMMENTVALUE ---------------------------------------------------------
_uncommentvalue ()
{
# Uncomment out a value in "standard" bash format. For example, given a
# file with a commented out variable defined like this:
#
# #VARNAME=valuehere
#
# the value can be UNcommented out to look like this:
#
# VARNAME=valuehere
#
# using this function:
#
# _uncommentoutvalue VARNAME "path/to/file.conf"
#
valuename="$1" filepath="$2";
sed -i "s/^#\(${valuename}.*\)$/\1/" "${filepath}";
}

# ADDTOLIST --------------------------------------------------------------
_addtolist ()
{
# Add to an existing list format variable (simple space delimited list)
# such as VARNAME="item1 item2 item3".
#
# If filepath is provided as third argument, this is changed in a file.
# If no filepath is provided, the change is made to a script-local
# variable.
#
# Usage (internal variable)
# _addtolist "newitem" LIST_VAR_NAME
#
# Usage (change in file)
# _addtolist "newitem" LIST_VAR_NAME "path/to/file"
#
if [ "$#" -lt 3 ]; then
:
else # add to list variable in an existing file
newitem="$1" listname="$2" filepath="$3";
sed -i "s/\(${listname}.*\)\()\)/\1 ${newitem}\2/" "${filepath}";
fi
}

# ANYKEY -----------------------------------------------------------------
_anykey ()
{
# Provide an alert (with optional custom preliminary message) and pause.
#
# Usage:
# _anykey "optional custom message"
#
echo -e "\n$@"; read -sn 1 -p "Any key to continue..."; echo;
}

# INSTALLPKG -------------------------------------------------------------
_installpkg ()
{
# Install package(s) from official repositories, no confirmation needed.
# Takes single or multiple package names as arguments.
#
# Usage:
# _installpkg pkgname1 [pkgname2] [pkgname3]
#
pacman -S --noconfirm "$@";
}

# INSTALLAUR -------------------------------------------------------------
_installaur ()
{
# Install package(s) from arch user repository, no confirmation needed.
# Takes single or multiple package names as arguments.
#
# Installs default helper first ($AURHELPER)
#
# Usage:
# _installpkg pkgname1 [pkgname2] [pkgname3]
#
_defaultvalue AURHELPER packer
if command -v $AURHELPER >/dev/null 2>&1; then
    $AURHELPER -S --noconfirm "$@";
else
    pkg=$AURHELPER; orig="$(pwd)"; mkdir -p /tmp/${pkg}; cd /tmp/${pkg};
    for req in wget git jshon; do
        command -v $req >/dev/null 2>&1 || _installpkg $req;
    done
    wget "https://aur.archlinux.org/packages/${pkg}/${pkg}.tar.gz";
    tar -xzvf ${pkg}.tar.gz; cd ${pkg};
    makepkg --asroot -si --noconfirm; cd "$orig"; rm -rf /tmp/${pkg};
    $AURHELPER -S --noconfirm "$@";
fi;
}

# CHROOT POSTSCRIPT ------------------------------------------------------
_chroot_postscript ()
{
cp "${0}" "${MNT}${POSTSCRIPT}";
chmod a+x "${MNT}${POSTSCRIPT}"; arch-chroot "${MNT}" "${POSTSCRIPT}";
}

# WARN -------------------------------------------------------------------
_initialwarning ()
{
_anykey "WARNING: This script will permanently erase the install drive.";
sleep 1
_anykey "CONFIRM: Please confirm again to proceed. CTRL-c to exit."

}

# LOAD BLOCK -------------------------------------------------------------
_loadblock ()
{
for _block in "$@"; do

isurl=false ispath=false isrootpath=false;

case "$_block" in
    *://*) isurl=true ;;
    /*)    isrootpath=true ;;
    */*)   ispath=true ;;
esac

FILE="${_block/%.sh/}.sh";

if $isurl; then URL="${FILE}";
elif [ -f "${DIR/%\//}/${FILE}" ]; then URL="file://${FILE}"
else URL="${REMOTE/%\//}/blocks/${FILE}"; fi

eval "$(curl -fsL ${URL})";

done
} 

# LOAD EFIVARS MODULE ----------------------------------------------------
_load_efi_modules ()
{
# Load efivars (or confirm they've loaded already) and set EFI_MODE for
# later use by bootloader.
#
modprobe efivars || true;
ls -l /sys/firmware/efi/vars/ &>/dev/null && return 0 || return 1;
}

# NULL FUNCTIONS (OVERRIDDEN BY EPONYMOUS BLOCKS)-------------------------
_filesystem_pre_baseinstall () { :; }
_filesystem_post_baseinstall () { :; }
_filesystem_pre_chroot () { :; }
_filesystem_post_chroot () { :; }





# CLEANUP BELOW:

#PRIMARY_BOOTLOADER="$(echo "$PRIMARY_BOOTLOADER" | tr [:lower:] [:upper:])";
#[ "${PRIMARY_BOOTLOADER#U}" == "EFI" ] && _load_efi_modules && EFI_MODE=true || EFI_MODE=false


#TODO: should add a first-run (first call to function for each phase) check and initialization phase
