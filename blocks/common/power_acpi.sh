# power
# ------------------------------------------------------------------------
_installpkg acpi acpid cpupower powertop
_daemon_add @acpi

#sed -i "/^DAEMONS/ s/)/ @acpid)/" /etc/rc.conf
#sed -i "/^MODULES/ s/)/ acpi-cpufreq cpufreq_ondemand cpufreq_powersave coretemp)/" /etc/rc.conf
# following requires my acpi handler script
#echo "/etc/acpi/handler.sh boot" > /etc/rc.local
#TODO: https://wiki.archlinux.org/index.php/Acpi - review this
