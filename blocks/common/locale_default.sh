#!/bin/bash
#
# LOCALE

_uncommentvalue ${LANGUAGE} /etc/locale.gen; locale-gen
export LANG=${LANGUAGE}; echo -e "LANG=${LANGUAGE}\nLC_COLLATE=C" > /etc/locale.conf
echo -e "KEYMAP=${KEYMAP}\nFONT=${FONT}\nFONT_MAP=${FONT_MAP}" > /etc/vconsole.conf

