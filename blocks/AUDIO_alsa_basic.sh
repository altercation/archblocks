# sound
# ------------------------------------------------------------------------
InstallPackage alsa-utils alsa-plugins
sed -i "/^DAEMONS/ s/)/ @alsa)/" /etc/rc.conf
mv /etc/asound.conf /etc/asound.conf.orig || true
#if alsamixer isn't working, try alsamixer -Dhw and speaker-test -Dhw -c 2


