#!/bin/bash

# video - intel

_installpkg xf86-video-intel

echo "options i915 modeset=1" > /etc/modprobe.d/i915.conf

cat > /etc/X11/xorg.conf.d/20-intel.conf << EOF
Section "Device"
	Identifier  "Intel Graphics"
	Driver      "intel"
	Option      "AccelMethod"  "sna"
	Option      "TearFree" "true"
EndSection
EOF