#!/bin/bash

# INIT - systemd, pure

# as per the Arch Linux wiki page on systemd: https://wiki.archlinux.org/index.php/Systemd

# 1. Install systemd from the official repositories.

_installpkg systemd systemd-sysvcompat 

# 2. Add init=/bin/systemd to the kernel parameters in your bootloader.

KERNEL_PARAMS="${KERNEL_PARAMS:+${KERNEL_PARAMS} }init=/bin/systemd"

# 3. Create systemd configuration files.

# this is taken care of in the blocks (which are, for the most part, systemd ready)

# 4. Enable daemons formerly listed in /etc/rc.conf with systemctl enable daemonname.service . For a translation of the daemons from /etc/rc.conf to systemd services, see: List of Daemons and Services

#TODO

# 5. Reboot. Your system should now initialize with systemd. If you are satisfied, remove the init=... entry.

# 6. Install systemd-sysvcompat. This conflicts with initscripts and sysvinit, and will prompt you to remove them.

#daemon_enable
#daemon_disable
#daemon_remove

