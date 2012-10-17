#!/bin/bash

# x - fonts
# ------------------------------------------------------------------------
_installpkg xorg-xlsfonts
_installpkg terminus-font
_installaur webcore-fonts
_installaur ttf-google-webfonts
#_installaur ttf-source-code-pro
#_installaur ttf-source-sans-pro
_installaur otf-source-code-pro
_installaur otf-source-sans-pro
_installaur libspiro
_installaur fontforge
_installpkg fontconfig
pacman -R --noconfirm freetype2
_installaur freetype2-git-infinality fontconfig-infinality-git
