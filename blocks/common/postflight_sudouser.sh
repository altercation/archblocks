#!/bin/bash

# sudo
# ------------------------------------------------------------------------
_installpkg sudo
cp /etc/sudoers /etc/sudoers.orig
cp /etc/sudoers /tmp/sudoers.edit

MATCH="%wheel.ALL=(ALL).ALL"
sed -i "s/^#\s*\(${MATCH}\)/\1/" /tmp/sudoers.edit

MATCH="%sudo.ALL=(ALL).ALL"
sed -i "s/^#\s*\(${MATCH}\)/\1/" /tmp/sudoers.edit

visudo -qcsf /tmp/sudoers.edit && cat /tmp/sudoers.edit > /etc/sudoers 

# make sure we have the right permissions and ownership
chown -c root:root /etc/sudoers
chmod -c 0440 /etc/sudoers

# add user
# ------------------------------------------------------------------------
echo -e "\nNew non-root user password (username:${USERNAME})\n"
groupadd sudo
useradd -m -g users -G audio,lp,optical,storage,video,games,power,scanner,network,sudo,wheel -s ${USERSHELL} ${USERNAME}
passwd ${USERNAME}

