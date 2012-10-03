#!/bin/bash

# sudo
# ------------------------------------------------------------------------
_installpkg sudo bash-completion # bash-completion to allow completion even when enter sudo command
[ ! -e /etc/sudoers.orig ] && cp /etc/sudoers /etc/sudoers.orig
[ -e /tmp/sudoers.edit ] && rm /tmp/sudoers.edit

#MATCH="%wheel.ALL=(ALL).ALL"
#sed -i "s/^#\s*\(${MATCH}\)/\1/" /tmp/sudoers.edit

#MATCH="%sudo.ALL=(ALL).ALL"
#sed -i "s/^#\s*\(${MATCH}\)/\1/" /tmp/sudoers.edit

cat > /tmp/sudoers.edit << EOF
Cmnd_Alias SYSUTILS = /bin/nice, /bin/kill, /usr/bin/nice, /usr/bin/ionice, /usr/bin/top, /usr/bin/kill, /usr/bin/killall, /usr/bin/ps, /usr/bin/pkill, /usr/bin/pacman, /usr/sbin/lsof, /bin/nice, /bin/ps, /usr/bin/top, /usr/local/bin/nano, /bin/netstat, /usr/bin/locate, /usr/bin/find, /usr/bin/rsync
Cmnd_Alias EDITORS = /usr/bin/vim, /usr/bin/nano, /usr/bin/cat, /usr/bin/vi
Cmnd_Alias NETWORKING = /usr/bin/wpa_supplicant, /usr/bin/wpa_cli, /usr/bin/wpa_passphrase, /usr/bin/iw

# a little redundant
root ALL = (ALL) ALL
%wheel    ALL=(ALL) ALL
%sudo     ALL=(ALL) ALL
USER_NAME ALL = (ALL) ALL, NOPASSWD: NETWORKING, NOPASSWD: SYSUTILS, NOPASSWD: EDITORS
 
Defaults !requiretty, !tty_tickets, !umask
Defaults visiblepw, path_info, insults, lecture=always
Defaults loglinelen = 0, logfile =/var/log/sudo.log, log_year, log_host, syslog=auth
Defaults mailto=es@ethanschoonover.com, mail_badpass, mail_no_user, mail_no_perms
Defaults passwd_tries = 8, passwd_timeout = 1
Defaults env_reset, always_set_home, set_home, set_logname
Defaults !env_editor, editor="/usr/bin/vim:/usr/bin/vi:/usr/bin/nano"
Defaults timestamp_timeout=360
Defaults passprompt="Sudo invoked by [%u] on [%H] - Cmd run as %U - Password for user %p:"
Defaults insults

# allow sudo to start x
Defaults env_keep += "HOME"
EOF

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

