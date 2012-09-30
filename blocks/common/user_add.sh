# ------------------------------------------------------------------------
# 10 POSTFLIGHT CUSTOMIZATIONS
# ------------------------------------------------------------------------
# functions (these could be a library, but why overcomplicate things
# ------------------------------------------------------------------------

# sudo
# ------------------------------------------------------------------------
_installpkg sudo
cp /etc/sudoers /tmp/sudoers.edit
sed -i "s/#\s*\(%wheel\s*ALL=(ALL)\s*ALL.*$\)/\1/" /tmp/sudoers.edit
sed -i "s/#\s*\(%sudo\s*ALL=(ALL)\s*ALL.*$\)/\1/" /tmp/sudoers.edit
visudo -qcsf /tmp/sudoers.edit && cat /tmp/sudoers.edit > /etc/sudoers 

# root password
# ------------------------------------------------------------------------
echo -e "${HR}\\nNew root user password\\n${HR}"
passwd

# add user
# ------------------------------------------------------------------------
echo -e "${HR}\\nNew non-root user password (username:${USERNAME})\\n${HR}"
groupadd sudo
useradd -m -g users -G audio,lp,optical,storage,video,games,power,scanner,network,sudo,wheel -s ${USERSHELL} ${USERNAME}
passwd ${USERNAME}

