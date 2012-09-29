# ------------------------------------------------------------------------
# BOOTLOADER
# ------------------------------------------------------------------------


EFI_SYSTEM_PARTITION="${EFI_SYSTEM_PARTITION:-/boot/efi}" # only if not yet set
[ ! -d "${EFI_SYSTEM_PARTITION}" ] && mkdir -p "${EFI_SYSTEM_PARTITION}"

# if we want to allow install on non-efi booted systems
# this will allow install the gummiboot loader to the default location of
# $esp/EFI/BOOT/BOOTX64.EFI
FAIL_TO_DEFAULT_EFI=${FAIL_TO_DEFAULT:-true} # only if not yet set

_load_efi_modules && EFI_MODE=true || EFI_MODE=false

_installpkg wget efibootmgr gummiboot-efi
install -Dm0644 /usr/lib/gummiboot/gummibootx64.efi /boot/efi/EFI/gummiboot/gummiboot.efi

if $EFI_MODE; then
    efibootmgr -c -L "Gummiboot" -l '\EFI\gummiboot\gummiboot.efi'
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
options        initrd=\\EFI\\arch\initramfs-linux.img "${KERNEL_PARAMS}"
GUMMIENTRIES
