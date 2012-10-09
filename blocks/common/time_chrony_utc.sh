#/!bin/bash
#
# TIME

ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime
echo ${TIMEZONE} >> /etc/timezone
hwclock --systohc --utc # set hardware clock
_installpkg chrony

if _systemd; then
    systemctl enable chrony.service
else
    sed -i "/^DAEMONS/ s/hwclock /!hwclock chrony /" /etc/rc.conf
fi

#cat >> /etc/chrony.conf << EOF
#
#server 0.pool.ntp.org offline
#server 1.pool.ntp.org offline
#server 2.pool.ntp.org offline
#server 3.pool.ntp.org offline
#EOF

cat >> /etc/chrony.conf << EOF

server 0.pool.ntp.org offline
server 1.pool.ntp.org offline
server 2.pool.ntp.org offline
server 3.pool.ntp.org offline
EOF
