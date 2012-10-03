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

_daemon_remove network
_daemon_add net-auto-wireless net-auto-wired ifplugd net-profiles
