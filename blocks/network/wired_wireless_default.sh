# ------------------------------------------------------------------------
# NETWORK
# ------------------------------------------------------------------------
_installpkg netcfg
_installpkg coreutils
_installpkg dhcpcd
_installpkg iproute2
_installpkg bridge-utils # (optional) - for bridge connections
_installpkg dialog # (optional) - for the menu based profile and wifi selectors
_installpkg ifenslave # (optional) - for bond connections
_installpkg ifplugd # (optional) - for automatic wired connections through net-auto-wired
_installpkg wireless_tools # (optional) - for interface renaming through net-rename
_installpkg wpa_actiond # (optional) - for automatic wireless connections through net-auto-wireless
_installpkg wpa_supplicant # (optional) - for wireless networking support

if _systemd; then
    systemctl enable net-auto-wired.service
    systemctl enable net-auto-wireless.service
    # systemctl enable netcfg.service # - uses profiles listed in /etc/conf.d/netcfg NETWORKS=(...)
    # systemctl enable netcfg@PROFILENAME.service
else
    _daemon_remove network
    _daemon_add net-auto-wireless net-auto-wired ifplugd net-profiles
fi

mv /etc/wpa_supplicant/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf.orig
echo -e "ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=network\nupdate_config=1" > /etc/wpa_supplicant/wpa_supplicant.conf

cat > /usr/bin/wifi << EOF
#!/bin/bash
#
# wifi: helper script for wifi-menu
#
# You can set /usr/bin/wifi-menu to allow use without passwords in /etc/sudoers (via visudo)
# but wifi-menu still only checks if you are root or sudoing, unlike netcfg.
# This simply wraps wifi-menu in sudo.

sudo wifi-menu $@
EOF
chmod a+x /usr/bin/wifi
