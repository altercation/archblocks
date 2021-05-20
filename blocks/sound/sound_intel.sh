#!/bin/bash
#
# sound card related

echo "options snd_hda_intel probe_only=0,1" > /etc/modprobe.d/snd_hda_intel.conf 

_installpkg alsa-utils pulseaudio pulseaudio-alsa alsa-tools