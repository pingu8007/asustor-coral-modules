#!/bin/sh
# Example ADM startup script for the Coral Edge TPU PCIe driver.
#
# Install: copy gasket.ko and apex.ko to MODULE_DIR, then place this script
# where ADM runs startup scripts (for example /usr/local/etc/init.d/ with an
# S-prefixed name) and make it executable.
#
# Uses only commands available in the BusyBox shipped with ADM.

# Directory holding gasket.ko and apex.ko. Defaults to this script's own
# directory; set it to a fixed path if the script lives elsewhere.
MODULE_DIR="${MODULE_DIR:-$(cd "$(dirname "$0")" && pwd)}"

loaded() {
	lsmod | grep -q "^$1 "
}

start() {
	for m in gasket apex; do
		if loaded "$m"; then
			echo "Coral TPU driver: $m already loaded"
		elif insmod "$MODULE_DIR/$m.ko"; then
			echo "Coral TPU driver: $m loaded"
		else
			# Typical cause after an ADM update: the kernel changed and
			# the modules must be rebuilt. See dmesg for the reason.
			echo "Coral TPU driver: failed to load $m.ko" >&2
			return 1
		fi
	done
}

stop() {
	# Fails harmlessly while a process still has /dev/apex_* open.
	for m in apex gasket; do
		if loaded "$m"; then
			rmmod "$m" || return 1
		fi
	done
}

case "$1" in
start)
	start
	;;
stop)
	stop
	;;
restart | reload | force-reload)
	stop && start
	;;
*)
	echo "Usage: $0 {start|stop|restart|reload|force-reload}"
	exit 2
	;;
esac
