#!/bin/bash


# Remember ldapproxy version if it exists.
if [ -x "/usr/share/centrifydc/libexec/slapd" ]; then
    SLAPD_VER="`/usr/share/centrifydc/libexec/slapd -V 2>&1 | grep Centrify | cut -d' ' -f3`"
    if [ ! -z "$SLAPD_VER" ]; then
        echo "$SLAPD_VER" > /var/centrifydc/upgrade/SLAPD_VER
        SLAPD_VER="`cat /var/centrifydc/upgrade/SLAPD_VER`"
        echo "found slapd version is $SLAPD_VER" 
    fi
fi
