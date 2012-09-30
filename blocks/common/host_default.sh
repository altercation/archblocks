#!/bin/bash
#
# HOST

echo ${HOSTNAME} > /etc/hostname; sed -i "s/localhost\.localdomain/${HOSTNAME}/g" /etc/hosts


