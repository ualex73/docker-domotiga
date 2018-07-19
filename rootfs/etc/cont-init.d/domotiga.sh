#!/usr/bin/with-contenv sh

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

# Generate machine id.
echo "Generating machine-id..."
cat /proc/sys/kernel/random/uuid | tr -d '-' > /etc/machine-id

mkdir -p /domotiga/config

# Take ownership of the config directory content.
chown -R $USER_ID:$GROUP_ID /domotiga/config
chown -R $USER_ID:$GROUP_ID /domotiga/logs
chown -R $USER_ID:$GROUP_ID /domotiga/rrd

exit 0

# vim: set ft=sh :

