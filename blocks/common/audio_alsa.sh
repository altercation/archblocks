# sound
# ------------------------------------------------------------------------
_installpkg alsa-utils alsa-plugins
sed -i "/^DAEMONS/ s/)/ @alsa)/" /etc/rc.conf
#[ -e /etc/asound.conf ] && mv /etc/asound.conf /etc/asound.conf.orig
#if alsamixer isn't working, try alsamixer -Dhw and speaker-test -Dhw -c 2


