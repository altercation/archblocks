#!/bin/bash
#
# alsa sound
# ------------------------------------------------------------------------

_installpkg alsa-utils alsa-plugins

if _systemd; then
    systemctl enable alsa-store.service
    systemctl enable alsa-restore.service
else
    _daemon_add @alsa
fi

# if alsamixer isn't working, try alsamixer -Dhw and speaker-test -Dhw -c 2


