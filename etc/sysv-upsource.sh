#!/bin/sh
### BEGIN INIT INFO
# Provides:          upsource
# Required-Start:    
# Required-Stop:
# Should-Start:      
# Default-Start:     
# Default-Stop:
# X-Interactive:     true
# Short-Description: Setup/update file from sources
### END INIT INFO

set -e

# This script is used jointly by console-setup and console-setup-mini.
# It belongs to keyboard-configuration because it is forbidden two
# different packages to share common configuration file.

if [ -f /etc/default/locale ]; then
    # In order to permit auto-detection of the charmap when
    # console-setup-mini operates without configuration file.
    . /etc/default/locale
    export LANG
fi

if [ -f /lib/lsb/init-functions ]; then
    . /lib/lsb/init-functions
else
    log_action_begin_msg () {
	echo -n "$@... "
    }

    log_action_end_msg () {
	if [ "$1" -eq 0 ]; then 
	    echo done.
	else
	    echo failed.
	fi
    }
fi

case "$1" in
    stop|status)
        # this isn't a daemon
        ;;
    start|force-reload|restart|reload)
	/usr/bin/upsource /etc/srcmap
	;;
    *)
        echo 'Usage: /etc/init.d/upsource {start|reload|restart|force-reload|stop|status}'
        exit 1
        ;;
esac

exit 0
