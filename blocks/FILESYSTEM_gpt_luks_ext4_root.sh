# ------------------------------------------------------------------------
# FILESYSTEM
#

DRIVE=${DRIVE:-/dev/sda}
PARTITION_EFI_BOOT=1
PARTITION_CRYPT_SWAP=2
PARTITION_CRYPT_ROOT=3
LABEL_BOOT_EFI=bootefi
LABEL_SWAP=swap
LABEL_SWAP_CRYPT=cryptswap
LABEL_ROOT=root
LABEL_ROOT_CRYPT=cryptroot
MOUNT_PATH=/mnt
EFI_BOOT_PATH=/boot/efi

FILESYSTEM_PRE_BASEINSTALL () {
# Here we create three partitions:
# 1. efi and /boot (one partition does double duty)
# 2. swap
# 3. our encrypted root
# Note that all of these are on a GUID partition table scheme. This proves
# to be quite clean and simple since we're not doing anything with MBR
# boot partitions and the like.

# disk prep
sgdisk -Z ${DRIVE} # zap all on disk
sgdisk -a 2048 -o ${DRIVE} # new gpt disk 2048 alignment

# create partitions
sgdisk -n ${PARTITION_EFI_BOOT}:0:+200M ${DRIVE} # (UEFI BOOT), default start block, 200MB
sgdisk -n ${PARTITION_CRYPT_SWAP}:0:+2G ${DRIVE} # (SWAP), default start block, 2GB
sgdisk -n ${PARTITION_CRYPT_ROOT}:0:0 ${DRIVE}   # (LUKS), default start, remaining space

# set partition types
sgdisk -t ${PARTITION_EFI_BOOT}:ef00 ${DRIVE}
sgdisk -t ${PARTITION_CRYPT_SWAP}:8200 ${DRIVE}
sgdisk -t ${PARTITION_CRYPT_ROOT}:8300 ${DRIVE}

# label partitions
sgdisk -c ${PARTITION_EFI_BOOT}:"${LABEL_BOOT_EFI}" ${DRIVE}
sgdisk -c ${PARTITION_CRYPT_SWAP}:"${LABEL_SWAP}" ${DRIVE}
sgdisk -c ${PARTITION_CRYPT_ROOT}:"${LABEL_ROOT}" ${DRIVE}

# format LUKS on root
cryptsetup --cipher=aes-xts-plain --verify-passphrase --key-size=512 \
luksFormat ${DRIVE}${PARTITION_CRYPT_ROOT}
cryptsetup luksOpen ${DRIVE}${PARTITION_CRYPT_ROOT} ${LABEL_ROOT_CRYPT}

# make filesystems
mkfs.vfat ${DRIVE}${PARTITION_EFI_BOOT}
mkfs.ext4 /dev/mapper/${LABEL_ROOT_CRYPT}

# mount target
# mkdir ${MOUNT_PATH}
mount /dev/mapper/${LABEL_ROOT_CRYPT} ${MOUNT_PATH}
mkdir -p ${MOUNT_PATH}${EFI_BOOT_PATH}
mount -t vfat ${DRIVE}${PARTITION_EFI_BOOT} ${MOUNT_PATH}${EFI_BOOT_PATH}
}

FILESYSTEM_POST_BASEINSTALL () {
# write to crypttab
# note: only /dev/disk/by-partuuid, /dev/disk/by-partlabel and
# /dev/sda2 formats work here
cat > ${MOUNT_PATH}/etc/crypttab <<CRYPTTAB_EOF
${LABEL_SWAP_CRYPT} /dev/disk/by-partlabel/${LABEL_SWAP} \
/dev/urandom swap,allow-discards
CRYPTTAB_EOF

# not using genfstab here since it doesn't record partlabel labels
cat > ${MOUNT_PATH}/etc/fstab <<FSTAB_EOF
# /etc/fstab: static file system information
#
# <file system>					<dir>		<type>	<options>				<dump>	<pass>
tmpfs						/tmp		tmpfs	nodev,nosuid				0	0
/dev/mapper/${LABEL_ROOT_CRYPT}			/      		ext4	rw,relatime,data=ordered,discard	0	1
/dev/disk/by-partlabel/${LABEL_BOOT_EFI}	$EFI_BOOT_PATH	vfat	rw,relatime,discard			0	2
/dev/mapper/${LABEL_SWAP_CRYPT}			none		swap	defaults,discard			0	0
FSTAB_EOF
}

FILESYSTEM_PRE_CHROOT () { umount ${MOUNT_PATH}${EFI_BOOT_PATH}; }
FILESYSTEM_POST_CHROOT () {
LoadEFIModules || exit
mount -t vfat ${DRIVE}${PARTITION_EFI_BOOT} ${EFI_BOOT_PATH};
}


