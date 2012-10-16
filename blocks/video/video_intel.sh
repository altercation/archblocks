#!/bin/bash

# video - intel

_installpkg xf86-video-intel lib32-intel-dri libva-intel-driver

cat > /etc/X11/xorg.conf.d/20-intel.conf << EOF
Section "Device"
	Identifier  "Intel Graphics"
	Driver      "intel"
	Option      "AccelMethod"  "sna"
EndSection
EOF
