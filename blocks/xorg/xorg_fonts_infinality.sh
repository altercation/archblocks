#!/bin/bash

# x - fonts
# ------------------------------------------------------------------------
_installpkg xorg-xlsfonts
_installpkg terminus-font
_installaur webcore-fonts
_installaur ttf-google-webfonts
_installaur libspiro
_installaur fontforge
_installpkg fontconfig
pacman -R --noconfirm freetype2
_installaur freetype2-git-infinality fontconfig-infinality-git
