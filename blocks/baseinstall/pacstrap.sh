# ------------------------------------------------------------------------
# BASEINSTALL
# ------------------------------------------------------------------------

# makes filesystem (provided by FILESYSTEM block)
_filesystem_pre_baseinstall

# standard pacstrap helper script
pacstrap ${MOUNT_PATH} base base-devel

# write filesystem configs (provided by FILESYSTEM block)
_filesystem_post_baseinstall

# unmount efi boot part (provided by FILESYSTEM block)
_filesystem_pre_chroot

# arch-chroot and proceed with script
_chroot_postscript
