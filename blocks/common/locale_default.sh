#!/bin/bash
#
# LOCALE

_uncommentvalue ${LANGUAGE} /etc/locale.gen; locale-gen
export LANG=${LANGUAGE}; echo LANG=${LANGUAGE} > /etc/locale.conf
echo -e "KEYMAP=${KEYMAP}\nFONT=${FONT}\nFONT_MAP=${FONT_MAP}" > /etc/vconsole.conf

