# x
# ------------------------------------------------------------------------
InstallPackage xorg xorg-server xorg-xinit xorg-utils xorg-server-utils xdotool xorg-xlsfonts
InstallPackage xf86-input-wacom
#AURInstallPackage xf86-input-wacom-git

# fonts
# ------------------------------------------------------------------------
InstallPackage terminus-font
InstallAURPackage webcore-fonts
InstallAURPackage libspiro
InstallAURPackage fontforge
packer -S freetype2-git-infinality # will prompt for freetype2 replacement
# TODO: sed infinality and change to OSX or OSX2 mode
#	and create the sym link from /etc/fonts/conf.avail to conf.d

