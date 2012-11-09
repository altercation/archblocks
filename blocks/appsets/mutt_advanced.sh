#!/bin/bash
#
# mutt, mta, mail indexing

_installpkg mutt offlineimap msmtp-mta
_installpkg python2-gdata python2-simplejson
_installaur goobook-git

cat > /etc/systemd/system/offlineimap-user.service << EOF
[Unit]
Description=Start offlineimap as a daemon

[Service]
User=$USERNAME
ExecStart=/usr/bin/offlineimap

[Install]
WantedBy=multi-user.target
EOF

systemctl enable offlineimap-user.service
