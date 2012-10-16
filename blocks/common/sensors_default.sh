#!/bin/bash
#
# sensors related packages

_installpkg lm_sensors
yes "" | sensors-detect
systemctl enable lm_sensors.service
