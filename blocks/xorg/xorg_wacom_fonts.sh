#!/bin/bash

# x
# ------------------------------------------------------------------------
_installpkg xorg xorg-server xorg-xinit xorg-utils xorg-server-utils xdotool xorg-xlsfonts
_installpkg xf86-input-wacom
#_installaur xf86-input-wacom-git

# fonts
# ------------------------------------------------------------------------
_installpkg terminus-font
_installaur webcore-fonts
_installaur ttf-google-webfonts
_installaur libspiro
_installaur fontforge
_installaur fontconfig-infinality-git
#packer -S freetype2-git-infinality # will prompt for freetype2 replacement
# TODO: sed infinality and change to OSX or OSX2 mode
#	and create the sym link from /etc/fonts/conf.avail to conf.d

