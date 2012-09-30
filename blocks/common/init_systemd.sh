# ------------------------------------------------------------------------
# SYSTEMD
# ------------------------------------------------------------------------

_installpkg systemd 

# KERNEL_PARAMS used by BOOTLOADER
KERNEL_PARAMS="${KERNEL_PARAMS:+${KERNEL_PARAMS} }init=/bin/systemd"

