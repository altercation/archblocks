# ------------------------------------------------------------------------
# BOOTLOADER
# ------------------------------------------------------------------------

# KERNEL_PARAMS get set up in FILESYSTEM and possibly other blocks like
# SYSTEMD

LoadEFIModules || exit
InstallPackage wget efibootmgr #gummiboot-efi-x86_64
InstallAURPackage gummiboot-efi-x86_64 #gummiboot in extra now
install -Dm0644 /usr/lib/gummiboot/gummiboot.efi /boot/efi/EFI/arch/gummiboot.efi
install -Dm0644 /usr/lib/gummiboot/gummiboot.efi /boot/efi/EFI/boot/bootx64.efi
efibootmgr -c -l '\EFI\arch\gummiboot.efi\' -L "Arch Linux"
cp /boot/vmlinuz-linux /boot/efi/EFI/arch/vmlinuz-linux.efi
cp /boot/initramfs-linux.img /boot/efi/EFI/arch/initramfs-linux.img
cp /boot/initramfs-linux-fallback.img /boot/efi/EFI/arch/initramfs-linux-fallback.img
mkdir -p ${EFI_BOOT_PATH}/loader/entries
cat >> ${EFI_BOOT_PATH}/loader/default.conf <<GUMMILOADER
default arch
timeout 4
GUMMILOADER
cat >> ${EFI_BOOT_PATH}/loader/entries/arch.conf <<GUMMIENTRIES
title          Arch Linux
efi            \\EFI\\arch\\vmlinuz-linux.efi
options        initrd=\\EFI\\arch\initramfs-linux.img "${KERNEL_PARAMS}"
GUMMIENTRIES

