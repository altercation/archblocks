#!/bin/bash
#
# acpi power
# https://wiki.archlinux.org/index.php/Acpi

_installpkg acpi acpid cpupower powertop

if _systemd; then
    systemctl enable acpid.service
else
    _daemon_add @acpi
fi

