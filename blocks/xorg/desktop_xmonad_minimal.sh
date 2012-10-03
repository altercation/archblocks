#!/bin/bash

_enable_haskell_repos

# install haskell-xmonad, related from haskell-testing

_installpkg haskell-xmonad haskell-xmonad-contrib haskell-xmonad-extras

# depending on xmonad config

_installpkg haskell-edit-distance

# environment/wm/etc.
# ------------------------------------------------------------------------
#_installpkg xfce4 compiz ccsm
_installpkg xcompmgr xscreensaver hsetroot
_installpkg rxvt-unicode urxvt-url-select
#_installaur rxvt-unicode-cvs # need to manually edit out patch lines
#_installpkg gtk2
#_installpkg ghc alex happy gtk2hs-buildtools cabal-install
_installaur physlock
_installpkg unclutter #TODO: consider hhp from xmonad-utils instead

#_installpkg dbus upower
#sed -i "/^DAEMONS/ s/)/ @dbus)/" /etc/rc.conf
