# ------------------------------------------------------------------------
# BOOTLOADER
# ------------------------------------------------------------------------

#EFI_LISTING_NAME="Gummiboot"
EFI_LISTING_NAME="Arch Linux"

EFI_SYSTEM_PARTITION="${EFI_SYSTEM_PARTITION:-/boot/efi}" # only if not yet set
[ ! -d "${EFI_SYSTEM_PARTITION}" ] && mkdir -p "${EFI_SYSTEM_PARTITION}"

# if we want to allow install on non-efi booted systems
# this will allow install the gummiboot loader to the default location of
# $esp/EFI/BOOT/BOOTX64.EFI
FAIL_TO_DEFAULT_EFI=${FAIL_TO_DEFAULT:-true} # only if not yet set

# this should now automatically be taken care of
#_load_efi_modules && EFI_MODE=true || EFI_MODE=false

# DEBUG TEST
ls -l /sys/firmware/efi/vars && EFI_MODE=true || EFI_MODE=false

_installpkg wget efibootmgr gummiboot-efi
install -Dm0644 /usr/lib/gummiboot/gummibootx64.efi /boot/efi/EFI/gummiboot/gummiboot.efi

if $EFI_MODE; then

    # BOOT_DRIVE must be set by filesystem to be used
    [ -n "$BOOT_DRIVE" ] && BOOT_ARG="-d $BOOT_DRIVE" || BOOT_ARG=""

    # delete if existing
    if efibootmgr | grep -q "$EFI_LISTING_NAME"; then
   	: 
    fi

    # write new bootloader entry
    efibootmgr -c -L "$EFI_LISTING_NAME" -l '\EFI\gummiboot\gummiboot.efi' $BOOT_ARG
    
elif $FAIL_TO_DEFAULT_EFI; then
    install -Dm0644 /usr/lib/gummiboot/gummibootx64.efi /boot/efi/EFI/BOOT/BOOTX64.EFI
else
    echo -e "\n\n>>>>> NOT BOOTED INTO EFI MODE"
    echo -e ">>>>>"
    echo -e ">>>>> Set FAIL_TO_DEFAULT_EFI to true to enable installation"
    echo -e ">>>>> of bootloader to default $esp/EFI/BOOT/BOOTX64.EFI location"
    exit 1
fi

ESP_ARCH="${EFI_SYSTEM_PARTITION}/EFI/arch"
[ -d "${ESP_ARCH}" ] || mkdir "${ESP_ARCH}"
cp /boot/vmlinuz-linux "${ESP_ARCH}/vmlinuz-linux.efi"
cp /boot/initramfs-linux.img "${ESP_ARCH}/initramfs-linux.img"
cp /boot/initramfs-linux-fallback.img "${ESP_ARCH}/initramfs-linux-fallback.img"
mkdir -p ${EFI_SYSTEM_PARTITION}/loader/entries
cat >> ${EFI_SYSTEM_PARTITION}/loader/default.conf <<GUMMILOADER
default arch
timeout 4
GUMMILOADER
cat >> ${EFI_SYSTEM_PARTITION}/loader/entries/arch.conf <<GUMMIENTRIES
title          Arch Linux
efi            \\EFI\\arch\\vmlinuz-linux.efi
options        initrd=\\EFI\\arch\initramfs-linux.img ${KERNEL_PARAMS}
GUMMIENTRIES

mkdir /etc/kernel
echo "${KERNEL_PARAMS}" > /etc/kernel/cmdline # for use in script below

# ------------------------------------------------------------------------
# POST KERNEL UPGRADE SYSTEMD SERVICE
# from https://github.com/grawity/code/tree/master/os/arch
# cf https://wiki.archlinux.org/index.php/UEFI_Bootloaders#Sync_EFISTUB_Kernel_in_UEFISYS_partition_using_Systemd
# ------------------------------------------------------------------------
if _systemd; then

cat > /etc/systemd/system/kernel-post-upgrade.path << 'EOF'
[Unit]
Description=Kernel post-upgrade watch

[Path]
PathChanged=/boot/vmlinuz-linux
PathChanged=/boot/initramfs-linux.img
PathChanged=/etc/kernel/cmdline

[Install]
WantedBy=multi-user.target
EOF

cat > /etc/systemd/system/kernel-post-upgrade.service << 'EOF'
[Unit]
Description=Kernel post-upgrade script

[Service]
Type=oneshot
ExecStart=/boot/kernel-post-upgrade.sh
EOF

cat > /etc/systemd/system/kernel-post-upgrade@.path << 'EOF'
[Unit]
Description=Kernel post-upgrade watch (for linux-%i)

[Path]
PathChanged=/boot/vmlinuz-linux-%i
PathChanged=/boot/initramfs-linux-%i.img
PathChanged=/etc/kernel/cmdline

[Install]
WantedBy=multi-user.target
EOF  

cat > /etc/systemd/system/kernel-post-upgrade@.service << 'EOF'
[Unit]
Description=Kernel post-upgrade script (for linux-%i)

[Service]
Type=oneshot
ExecStart=/boot/kernel-post-upgrade.sh linux-%i
EOF


cat > /boot/kernel-post-upgrade.sh << 'EOF'
#!/bin/bash -eu

die() {
	echo "$*" >&2
	exit 1
}

same_fs() {
	test "$(stat -c %d "$1")" = "$(stat -c %d "$2")"
}

list_configs() {
	find "$ESP/loader/entries" \
		\( -name "$ID.conf" -o -name "$ID-*.conf" \)\
		-printf '%f\n' | sed "s/^$ID/linux/; s/\.conf\$//"
}

check_all() {
	list-configs | while read kernel; do
		check_kernel "$kernel"
	done
}

check_kernel() {
	local kernel=$1
	local suffix=
	local config=$ID

	if [[ $kernel != 'linux' ]]; then
		suffix="-${kernel#linux-}"
		config=$config$suffix
	fi

	if [[ -e "/boot/vmlinuz-$kernel" ]]; then
		install_kernel
	else
		remove_kernel
	fi
}

install_kernel() {
	local version=

	if version=$(pacman -Q "$kernel" 2>/dev/null); then
		version=${version#"$kernel "}${suffix}
	else
		echo "error: package '$kernel' does not exist"
		return 1
	fi

	echo "Found $PRETTY_NAME ($kernel $version)"

	echo "+ copying kernel to EFI system partition"
	mkdir -p "$ESP/EFI/$ID"
	cp -f "/boot/vmlinuz-$kernel"		"$ESP/EFI/$ID/vmlinuz-$kernel.efi"
	cp -f "/boot/initramfs-$kernel.img"	"$ESP/EFI/$ID/initramfs-$kernel.img"

	parameters=(
		"title"		"$PRETTY_NAME"
		"title-version"	"$version"
		"title-machine"	"${MACHINE_ID:0:8}"
		"linux"		"\\EFI\\$ID\\vmlinuz-$kernel.efi"
		"initrd"	"\\EFI\\$ID\\initramfs-$kernel.img"
		"options"	"$BOOT_OPTIONS"
	)
	echo "+ generating bootloader config"
	mkdir -p "$ESP/loader/entries"
	printf '%s\t%s\n' "${parameters[@]}" > "$ESP/loader/entries/$config.conf"
}

remove_kernel() {
	echo "Uninstalling $PRETTY_NAME ($kernel)"

	echo "+ removing kernel from EFI system partition"
	rm -f "$ESP/EFI/$ID/vmlinuz-$kernel.efi"
	rm -f "$ESP/EFI/$ID/initramfs-$kernel.img"

	echo "+ removing bootloader config"
	rm -f "$ESP/loader/entries/$config.conf"
}

unset ID NAME PRETTY_NAME MACHINE_ID BOOT_OPTIONS

if [[ -d /boot/efi/EFI && -d /boot/efi/loader ]]; then
	ESP=/boot/efi
elif [[ -d /boot/EFI && -d /boot/loader ]]; then
	ESP=/boot
else
	die "error: EFI system partition not found; please \`mkdir <efisys>/loader\`"
fi

echo "Found EFI system partition at $ESP"

. /etc/os-release ||
	die "error: /etc/os-release not found or invalid; see os-release(5)"

[[ ${PRETTY_NAME:=$NAME} ]] ||
	die "error: /etc/os-release is missing both PRETTY_NAME and NAME; see os-release(5)"

[[ $ID ]] ||
	die "error: /etc/os-release is missing ID; see os-release(5)"

read -r MACHINE_ID < /etc/machine-id ||
	die "error: /etc/machine-id not found or empty; see machine-id(5)"

[[ -s /etc/kernel/cmdline ]] ||
	die "error: /etc/kernel/cmdline not found or empty; please configure it"

BOOT_OPTIONS=(`grep -v "^#" /etc/kernel/cmdline`)
BOOT_OPTIONS=${BOOT_OPTIONS[*]}

check_kernel "${1:-linux}"
EOF

# note: will have to enable this post reboot with:
# systemctl enable kernel-post-upgrade.path

echo "systemctl enable kernel-post-upgrade.path" >> /root/post-reboot.sh

fi
# ------------------------------------------------------------------------
