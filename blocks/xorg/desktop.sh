#!/bin/bash

_enable_haskell_repos

# install haskell-xmonad, related from haskell-testing

_installpkg ghc cabal-install haskell-xmonad haskell-xmonad-contrib haskell-xmonad-extras xmobar trayer dunst

# depending on xmonad config

_installpkg haskell-edit-distance

# environment/wm/etc.
# ------------------------------------------------------------------------
#_installpkg xfce4 compiz ccsm
_installpkg xscreensaver hsetroot
_installaur compton-git # xcompmgr no longer maintained

#_installpkg rxvt-unicode urxvt-url-select
_installaur kitty

#_installaur rxvt-unicode-cvs # need to manually edit out patch lines
#_installpkg gtk2
#_installpkg ghc alex happy gtk2hs-buildtools cabal-install
_installaur physlock
_installpkg unclutter #TODO: consider hhp from xmonad-utils instead

#_installpkg dbus upower
#sed -i "/^DAEMONS/ s/)/ @dbus)/" /etc/rc.conf

# onscreen keyboard
_installpkg onboard at-spi2-atk
