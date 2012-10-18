#!/bin/bash
#
# sound card related

# related to problem with intel hda codecs on system resume
# cf http://unix.stackexchange.com/questions/50498/hda-codec-and-hda-intel-issues
# cf http://bbs.archlinux.org/viewtopic.php?id=144962 

echo "options snd_hda_intel probe_only=0,1" > /etc/modprobe.d/snd_hda_intel.conf 
