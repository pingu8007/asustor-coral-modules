#!/bin/sh
# Load the Coral Edge TPU PCIe driver (gasket + apex). Run as root on the NAS.
# Uses only commands available in the BusyBox shipped with ADM.

DIR="$(cd "$(dirname "$0")" && pwd)"

loaded() {
	lsmod | grep -q "^$1 "
}

loaded gasket || insmod "$DIR/gasket.ko" || {
	echo "insmod gasket.ko failed; see: dmesg | tail -n 20" >&2
	exit 1
}

loaded apex || insmod "$DIR/apex.ko" || {
	echo "insmod apex.ko failed; see: dmesg | tail -n 20" >&2
	exit 1
}

sleep 1

if ls /dev/apex_* >/dev/null 2>&1; then
	ls -l /dev/apex_*
else
	echo "modules loaded but no /dev/apex_* device node; see: dmesg | tail -n 20" >&2
	exit 1
fi
