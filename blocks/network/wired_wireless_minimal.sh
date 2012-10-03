# ------------------------------------------------------------------------
# NETWORK
# ------------------------------------------------------------------------
_installpkg iw wpa_supplicant wpa_actiond rfkill
_addtolist net-auto-wireless DAEMONS /etc/rc.conf
