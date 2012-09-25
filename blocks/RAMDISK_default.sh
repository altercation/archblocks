# ------------------------------------------------------------------------
# RAMDISK
# ------------------------------------------------------------------------

# set default values if not set from variables in the config file
MODULES="${MODULES:-}"
HOOKS="${HOOKS:-base udev autodetect pata scsi sata filesystems usbinput fsck}"

cp /etc/mkinitcpio.conf /etc/mkinitcpio.orig
sed -i "s/^MODULES.*$/MODULES=\"${MODULES}\"/" /etc/mkinitcpio.conf
#sed -i "s/^HOOKS.*$/HOOKS=\"${HOOKS}\"/" /etc/mkinitcpio.conf
sed -i "s/\(^HOOKS.*\) filesystems \(.*$\)/\1 ${HOOKS} \2/" /etc/mkinitcpio.conf

set +e # even if mkinitcpio succeeds, set -e results in script abort
mkinitcpio -p linux
set -e
