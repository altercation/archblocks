# ------------------------------------------------------------------------
# LANGUAGE
# ------------------------------------------------------------------------
UncommentValue ${LANGUAGE} /etc/locale.gen
locale-gen
echo LANG=${LANGUAGE} > /etc/locale.conf
export LANG=${LANGUAGE}
cat > /etc/vconsole.conf <<VCONSOLECONF
KEYMAP=${KEYMAP}
FONT=${FONT}
FONT_MAP=
VCONSOLECONF
