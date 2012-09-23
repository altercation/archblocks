# ------------------------------------------------------------------------
# NETWORK
# ------------------------------------------------------------------------
InstallPackage wireless_tools netcfg wpa_supplicant wpa_actiond dialog
AddToList net-auto-wireless DAEMONS /etc/rc.conf
