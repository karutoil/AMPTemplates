#!/bin/bash

SCRIPT_NAME=$(echo \"$0\" | xargs readlink -f)
SCRIPTDIR=$(dirname "$SCRIPT_NAME")

exec 6>display.log
/usr/bin/Xvfb -displayfd 6 -nolisten tcp -nolisten unix &
XVFB_PID=$!
while [[ ! -s display.log ]]; do
  sleep 1
done
read -r DPY_NUM < display.log
rm display.log

export WINEPREFIX="$SCRIPTDIR/space-engineers-generic/.wine"
export WINEDLLOVERRIDES="mscoree,mshtml="
export WINEARCH=win64
export WINEDEBUG=fixme-all
export DISPLAY=:$DPY_NUM

wget -q -N https://raw.githubusercontent.com/Winetricks/winetricks/1d441b422d9a9cc8b0a53fa203557957ca1adc44/src/winetricks
chmod +x winetricks
wget -q -O $WINEPREFIX/mono.msi https://dl.winehq.org/wine/wine-mono/9.1.0/wine-mono-9.1.0-x86.msi

/usr/bin/wine msiexec /i $WINEPREFIX/mono.msi /qn /quiet /norestart /log $WINEPREFIX/mono_install.log

PACKAGES="win11 corefonts vcrun2022"
echo "" > winescript_log.txt 2>&1
for PACKAGE in $PACKAGES; do
  ./winetricks -q $PACKAGE >> winescript_log.txt 2>&1
done
rm -rf ~/.cache/winetricks ~/.cache/fontconfig

exec 6>&-
kill $XVFB_PID

exit 0
