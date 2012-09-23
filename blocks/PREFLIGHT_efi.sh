# ------------------------------------------------------------------------
# PREFLIGHT
# ------------------------------------------------------------------------

setfont $FONT
 modprobe efivars
if ls -1 /sys/firmware/efi/vars/ >/dev/null; then
echo "Booted into EFI mode, continuing..."
else
echo "Failed to boot into EFI mode, exiting..."
exit 1
fi
