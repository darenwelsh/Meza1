#!/bin/sh

#
# chkconfig: 35 99 99
# description: Node.js /etc/parsoid/api/server.js
#

# provides echo_success and echo_failure functions (amongst others)
. /etc/rc.d/init.d/functions

USER="parsoid"

DAEMON="/usr/local/bin/node"
ROOT_DIR="/etc/parsoid/api"

SERVER="$ROOT_DIR/server.js"
LOG_FILE="$ROOT_DIR/server.js.log"

LOCK_FILE="/var/lock/subsys/node-server"

get_parsoid_process_id()
{
	echo `ps -aefw | grep "$DAEMON $SERVER" | grep -v " grep " | awk '{print $2}'`
}
parsoid_start_echo_success()
{
	# Wait 10 seconds since paroid takes some time to start and we don't have a
	# good method to be told when it's up
	sleep 10
	echo_success # normal echo_success function
}
do_start()
{
    pid=$(get_parsoid_process_id)

    # if no parsoid process exists already
	if [ -z "$pid" ]; then

	    echo -n $"Starting $SERVER: "

	    # Use "nohup" to prevent hang-up. Thanks to:
	    # http://stackoverflow.com/questions/5818202/how-to-run-node-js-app-forever-when-console-is-closed
	    runuser -l "$USER" -c "nohup $DAEMON $SERVER >> $LOG_FILE 2>&1 &" && parsoid_start_echo_success || echo_failure
	    echo "" # newline after success/failure
	    RETVAL=$?
	else
	    echo "Parsoid already running with process ID = $pid"
	    RETVAL=1
	fi
}
do_stop()
{
    echo -n $"Stopping $SERVER: "
    # pid=`ps -aefw | grep "$DAEMON $SERVER" | grep -v " grep " | awk '{print $2}'`
    pid=$(get_parsoid_process_id)
    kill -9 $pid > /dev/null 2>&1 && echo_success || echo_failure
    echo "" # newline after success/failure
    RETVAL=$?
}

case "$1" in
        start)
                do_start
                ;;
        stop)
                do_stop
                ;;
        restart)
                do_stop
                do_start
                ;;
        *)
                echo "Usage: $0 {start|stop|restart}"
                RETVAL=1
esac

exit $RETVAL