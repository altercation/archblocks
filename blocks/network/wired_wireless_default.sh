# ------------------------------------------------------------------------
# NETWORK
# ------------------------------------------------------------------------
_installpkg wireless_tools netcfg wpa_supplicant wpa_actiond dialog
_addtolist net-auto-wireless DAEMONS /etc/rc.conf
