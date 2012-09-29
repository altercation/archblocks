# ------------------------------------------------------------------------
# NETWORK
# ------------------------------------------------------------------------
_installpkg iw wpa_supplicant wpa_actiond
_addtolist net-auto-wireless DAEMONS /etc/rc.conf
