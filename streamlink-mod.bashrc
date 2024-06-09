function streamlink-mod() {
    action=$1
    url=$2
    filename=$3
    pidfile="/tmp/streamlink_mod.pid"

    stop_monitor() {
        if [ -f $pidfile ]; then
            pid=$(cat $pidfile)
            if ps -p $pid > /dev/null; then
                kill $pid && rm -f $pidfile
                echo "Monitor stopped"
            else
                rm -f $pidfile
            fi
        fi
    }

    case $action in
        start)
            if [ "$#" -ne 3 ]; then
                echo "Usage: streamlink-mod start <URL> <FILENAME>"
                return 1
            fi

            stop_monitor

            python your/path/here/streamlink-mod.py "$url" "$filename" &
            echo $! > $pidfile
            echo "Monitor started"
            ;;
        stop)
            if [ "$#" -ne 1 ]; then
                echo "Usage: streamlink-mod stop"
                return 1
            fi
            stop_monitor
            echo "Monitor stopped"
            ;;
        *)
            echo "Usage: streamlink-mod start <URL> <FILENAME> | streamlink_mod stop"
            return 1
            ;;
    esac
}
