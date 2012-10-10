#/!bin/bash
#
# TIME

ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime
echo ${TIMEZONE} >> /etc/timezone
#hwclock --systohc --utc # set hardware clock
hwclock -w --utc # set hardware clock
_installpkg chrony

if _systemd; then
    systemctl enable chrony.service;
else
    sed -i "/^DAEMONS/ s/hwclock /!hwclock chrony /" /etc/rc.conf;
fi

mv /etc/chrony.conf /etc/chrony.conf.orig

cat > /etc/chrony.conf << EOF
driftfile /etc/chrony.drift
keyfile /etc/chrony.keys
commandkey 1
dumponexit
dumpdir /var/log/chrony
pidfile /var/run/chronyd.pid
cmdallow 127.0.0.1
rtcfile /etc/chrony.rtc
rtconutc
server 0.pool.ntp.org offline
server 1.pool.ntp.org offline
server 2.pool.ntp.org offline
server 3.pool.ntp.org offline
EOF

echo "1 mypassword" > /etc/chrony.keys

systemctl start chrony

_anykey "TESTING CHRONY >>>>>>"
# chronyc makestep to adjust if large differential
chronyc << EOF
password mypassword
online
makestep
trimrtc
writertc
EOF
_anykey "TESTING CHRONY >>>>>>"
