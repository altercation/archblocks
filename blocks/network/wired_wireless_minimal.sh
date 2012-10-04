# ------------------------------------------------------------------------
# NETWORK
# ------------------------------------------------------------------------
_installpkg iw wpa_supplicant wpa_actiond rfkill
_addtolist net-auto-wireless DAEMONS /etc/rc.conf

mv /etc/wpa_supplicant/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf.orig
echo -e "ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=network\nupdate_config=1" > /etc/wpa_supplicant/wpa_supplicant.conf
