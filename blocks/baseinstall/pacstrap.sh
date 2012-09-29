# ------------------------------------------------------------------------
# BASEINSTALL
# ------------------------------------------------------------------------

# makes filesystem (provided by FILESYSTEM block)
FILESYSTEM_PRE_BASEINSTALL

# standard pacstrap helper script
pacstrap ${MOUNT_PATH} base base-devel

# write filesystem configs (provided by FILESYSTEM block)
FILESYSTEM_POST_BASEINSTALL

# unmount efi boot part (provided by FILESYSTEM block)
FILESYSTEM_PRE_CHROOT

# arch-chroot and proceed with script
_chroot_postscript
