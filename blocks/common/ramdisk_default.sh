#!/bin/bash
#
# RAMDISK

cp /etc/mkinitcpio.conf /etc/mkinitcpio.orig
sed -i "s/^MODULES.*$/MODULES=\"${MODULES}\"/" /etc/mkinitcpio.conf
sed -i "s/^HOOKS.*$/HOOKS=\"${HOOKS}\"/" /etc/mkinitcpio.conf
mkinitcpio -p linux
