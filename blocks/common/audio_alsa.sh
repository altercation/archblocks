# sound
# ------------------------------------------------------------------------
_installpkg alsa-utils alsa-plugins
_daemon_add @alsa
# if alsamixer isn't working, try alsamixer -Dhw and speaker-test -Dhw -c 2


