# ------------------------------------------------------------------------
# FILESYSTEM
#

# queries if INSTALL_DRIVE not already set in main install-config file to valid 
# path (e.g. /dev/sda) or if INSTALL_DRIVE is set to "query"
_drivequery;

BOOT_DRIVE=$INSTALL_DRIVE # expected format /dev/sda
PARTITION_EFI_BOOT=1
LABEL_BOOT_EFI=bootefi
LABEL_SWAP=swap
LABEL_ROOT=root
MOUNT_PATH=/mnt
EFI_SYSTEM_PARTITION=/boot/efi

#_add_to_var MODULES "dm_mod dm_crypt aes_x86_64"

_filesystem_pre_baseinstall () {
_countdown 10 "ERASING $INSTALL_DRIVE"
# Here we create three partitions:
# 1. efi and /boot (one partition does double duty)
# 2. swap
# 3. our encrypted root
# Note that all of these are on a GUID partition table scheme. This proves
# to be quite clean and simple since we're not doing anything with MBR
# boot partitions and the like.

# disk prep
sgdisk -Z ${INSTALL_DRIVE} # zap all on disk
sgdisk -a 2048 -o ${INSTALL_DRIVE} # new gpt disk 2048 alignment

# create partitions
sgdisk -n ${PARTITION_EFI_BOOT}:0:+200M ${INSTALL_DRIVE} # (UEFI BOOT), default start block, 200MB
sgdisk -n ${PARTITION_SWAP}:0:+2G ${INSTALL_DRIVE} # (SWAP), default start block, 2GB
sgdisk -n ${PARTITION_ROOT}:0:0 ${INSTALL_DRIVE}   # (LUKS), default start, remaining space

# set partition types
sgdisk -t ${PARTITION_EFI_BOOT}:ef00 ${INSTALL_DRIVE}
sgdisk -t ${PARTITION_SWAP}:8200 ${INSTALL_DRIVE}
sgdisk -t ${PARTITION_ROOT}:8300 ${INSTALL_DRIVE}

# label partitions
sgdisk -c ${PARTITION_EFI_BOOT}:"${LABEL_BOOT_EFI}" ${INSTALL_DRIVE}
sgdisk -c ${PARTITION_SWAP}:"${LABEL_SWAP}" ${INSTALL_DRIVE}
sgdisk -c ${PARTITION_ROOT}:"${LABEL_ROOT}" ${INSTALL_DRIVE}

# make filesystems
mkfs.vfat ${INSTALL_DRIVE}${PARTITION_EFI_BOOT}
mkswap ${INSTALL_DRIVE}${PARTITION_SWAP}
swapon ${INSTALL_DRIVE}${PARTITION_SWAP}
mkfs.ext4 ${INSTALL_DRIVE}${PARTITION_ROOT}
# mkswap /dev/sda2

# mount target
mkdir -p ${MOUNT_PATH}
mount ${INSTALL_DRIVE}${PARTITION_ROOT} ${MOUNT_PATH}
mkdir -p ${MOUNT_PATH}${EFI_SYSTEM_PARTITION}
mount -t vfat ${INSTALL_DRIVE}${PARTITION_EFI_BOOT} ${MOUNT_PATH}${EFI_SYSTEM_PARTITION}
}

_filesystem_post_baseinstall () {
# not using genfstab here since it doesn't record partlabel labels
cat > ${MOUNT_PATH}/etc/fstab <<FSTAB_EOF
# /etc/fstab: static file system information
#
# <file system>					<dir>		<type>	<options>				<dump>	<pass>
tmpfs						/tmp		tmpfs	nodev,nosuid				0	0
#/dev/disk/by-partlabel/${LABEL_BOOT_EFI}		$EFI_SYSTEM_PARTITION	vfat	rw,relatime,discard			0	2
/dev/disk/by-partlabel/${LABEL_BOOT_EFI}		$EFI_SYSTEM_PARTITION	vfat	rw,relatime,discard,fmask=0022,dmask=0022,codepage=437,iocharset=iso8859-1,shortname=mixed,errors=remount-ro	0 2
/dev/disk/by-partlabel/${LABEL_SWAP}				none		swap	defaults,discard			0	0
/dev/disk/by-partlabel/${LABEL_ROOT}				/      		ext4	rw,relatime,data=ordered,discard	0	1
FSTAB_EOF
}

_filesystem_pre_chroot ()
{
umount ${MOUNT_PATH}${EFI_SYSTEM_PARTITION};
}

_filesystem_post_chroot ()
{
mount -t vfat ${INSTALL_DRIVE}${PARTITION_EFI_BOOT} ${EFI_SYSTEM_PARTITION} || return 1;
# KERNEL_PARAMS used by BOOTLOADER
# KERNEL_PARAMS="${KERNEL_PARAMS:+${KERNEL_PARAMS} }cryptdevice=/dev/sda3:${LABEL_ROOT_CRYPT} root=/dev/mapper/${LABEL_ROOT_CRYPT} ro rootfstype=ext4"
KERNEL_PARAMS="${KERNEL_PARAMS:+${KERNEL_PARAMS} }root=UUID=$(_get_uuid ${INSTALL_DRIVE}${PARTITION_ROOT}) ro rootfstype=ext4"
}
