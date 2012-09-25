# ------------------------------------------------------------------------
# RAMDISK
# ------------------------------------------------------------------------

MODULES="${MODULES:-}"
HOOKS="${HOOKS:-base udev autodetect pata scsi sata filesystems}"

echo -e "MODULES are:\n${MODULES}"
echo -e "HOOKS are:\n${HOOKS}"
AnyKey

sed -i "s/^MODULES.*$/MODULES=\"${MODULES}\"/" /etc/mkinitcpio.conf
sed -i "s/^HOOKS.*$/HOOKS=\"${HOOKS}\"/" /etc/mkinitcpio.conf

set +e # even if mkinitcpio succeeds, set -e results in script abort
mkinitcpio -p linux
set -e
