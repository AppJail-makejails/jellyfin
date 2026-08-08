#!/bin/sh

. /lib.subr

set -e

create_user

# Enable hardware acceleration.
pw groupmod -n video -m noroot

if [ ! -d "${JELLYFIN_DATA_DIR}" ]; then
    install -d -o noroot -g noroot "${JELLYFIN_DATA_DIR}"
fi

if [ ! -d "${JELLYFIN_CACHE_DIR}" ]; then
    install -d -o noroot -g noroot "${JELLYFIN_CACHE_DIR}"
fi

if [ ! -d "/tmp/jellyfin" ]; then
    install -d -o noroot -g noroot "/tmp/jellyfin"
fi

change_owner "${JELLYFIN_DATA_DIR}"
change_owner "${JELLYFIN_CACHE_DIR}"
change_owner "/tmp/jellyfin"

# .NET 6+ use dual mode sockets to avoid the separate AF handling.
# disable .NET use of V6 if no ipv6 is configured.
# See https://bugs.freebsd.org/bugzilla/show_bug.cgi?id=259194#c17
if ! ifconfig -a -u -G lo | grep -q inet6; then
    export DOTNET_SYSTEM_NET_DISABLEIPV6=1
fi

if [ `uname -K` -ge 1400092 ]; then
    export CLR_OPENSSL_VERSION_OVERRIDE=30
fi

exec su-exec noroot /usr/local/jellyfin/jellyfin "$@"
