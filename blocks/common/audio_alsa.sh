#!/bin/bash


_installpkg alsa-utils pulseaudio pulseaudio-alsa alsa-tools
if _systemd; then
    systemctl enable alsa-store.service
    systemctl enable alsa-restore.service
else
    _daemon_add @alsa
fi