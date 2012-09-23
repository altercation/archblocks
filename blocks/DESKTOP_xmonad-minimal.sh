# environment/wm/etc.
# ------------------------------------------------------------------------
#InstallPackage xfce4 compiz ccsm
InstallPackage xcompmgr xscreensaver hsetroot
InstallPackage rxvt-unicode urxvt-url-select
InstallAURPackage rxvt-unicode-cvs # need to manually edit out patch lines
InstallPackage urxvt-url-select
InstallPackage gtk2
InstallPackage ghc alex happy gtk2hs-buildtools cabal-install
InstallAURPackage physlock
InstallPackage unclutter #TODO: consider hhp from xmonad-utils instead
InstallPackage dbus upower
sed -i "/^DAEMONS/ s/)/ @dbus)/" /etc/rc.conf

