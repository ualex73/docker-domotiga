#!/bin/sh

# Need to be set, otherwise X11 will not work
export QT_X11_NO_MITSHM=1

# We need to use an external MySQL database, because onboard doesn't work with Ubuntu

echo "#### Starting DomotiGa ###"
exec /domotiga/DomotiGa3.gambas -c config/domotiga.conf

