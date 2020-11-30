#!/bin/env sh

server() {

    export SS_SERVER_PORT=${SERVER_PORT:-8388}
    export KCPTUN_TARGETSVC_PORT="${SS_SERVER_PORT}"

    ss-server \
        -s $SS_SERVER_BIND \
        -p $SS_SERVER_PORT \
        -k ${PASSWORD} \
        -m $METHOD \
        -t $TIMEOUT \
        -d $DNS_ADDRS \
        -u &

    # wait for ss-server
    until (nc -nz -w 1 $SS_SERVER_BIND $SS_SERVER_PORT) do 
        >&2 echo "$(date +%FT%T) ss is unavailibel"
        sleep 1
    done

    echo "ss is availibel, running kcptun-server"
    server_linux_amd64 \
        -l ${KCPTUN_SERVER_BIND}:${KCPTUN_SERVER_PORT} \
        -t ${KCPTUN_TARGETSVC_ADDR}:${KCPTUN_TARGETSVC_PORT}  \
        $KCPTUN_ARG
}



client() {

    print_usage() {
        echo "usage: $0 ss|kcptun"
        return 1
    }

    check() {
    	if [ "$1" != "ss" -a "$1" != "kcptun" ]; then
            print_usage
            return 1
        fi

        if [ "${SERVER_ADDR}" = "" ]; then
            echo "SERVER_ADDR variable is empty"
            return 1
        fi
    }

    run_privoxy() {
        grep -Ev "#|^$" /etc/privoxy/config  > /etc/privoxy/config.bak
        cat /etc/privoxy/config.bak > /etc/privoxy/config
        rm -f /etc/privoxy/config.bak
        sed -i '/listen-address/d' /etc/privoxy/config
        echo "listen-address  0.0.0.0:${PRIVOXY_LOCAL_PORT}" >> /etc/privoxy/config
        echo "forward-socks5 / 127.0.0.1:${SS_LOCAL_PORT} ." >> /etc/privoxy/config
    }

    run_kcptun() {
        exec \
            client_linux_amd64 \
            -r ${KCPTUN_SERVER_ADDR}:${KCPTUN_SERVER_PORT} \
            -l ${KCPTUN_LOCAL_BIND}:${KCPTUN_LOCAL_PORT} \
            ${KCPTUN_ARG}
    }

    run_sslocal() {
        exec \
            ss-local \
            -s ${SS_SERVER_ADDR} \
            -p ${SS_SERVER_PORT} \
            -b ${SS_LOCAL_BIND} \
            -l ${SS_LOCAL_PORT} \
            -k ${PASSWORD} \
            -m ${METHOD}
    }

    ss() {
        export SS_SERVER_ADDR=${SERVER_ADDR}
        export SS_SERVER_PORT=${SERVER_PORT:-8388}
        run_sslocal
    }

    kcptun() {
        export SS_SERVER_ADDR=${KCPTUN_LOCAL_BIND}
        export SS_SERVER_PORT=${KCPTUN_LOCAL_PORT}
        export KCPTUN_SERVER_ADDR=${SERVER_ADDR}
        export KCPTUN_TARGETSVC_PORT="${SERVER_PORT:-8388}"
        run_kcptun &
        run_sslocal
    }

    #if [ "$1" = "ss" ]; then
    #    export SS_SERVER_ADDR=${SERVER_ADDR}
    #fi
    #if [ "$1" = "kcptun" ]; then
    #    export KCPTUN_SERVER_ADDR=${SERVER_ADDR}
    #    export SS_SERVER_ADDR=${KCPTUN_LOCAL_BIND}
    #    export SS_SERVER_PORT=${KCPTUN_LOCAL_PORT}
    #fi

    check "$@"
    "$@"
}

print_usage() {
    echo "usage: $0 server|client ..."
    return 1
}

main() {
    if [ $# -eq 0 ]; then
        print_usage
        return 1
    fi

    if [ "$1" != "server" -a "$1" != "client" ]; then
        print_usage
        return 1
    fi

    if [ "${PASSWORD}" = "" ]; then
        echo "PASSWORD variable is empty"
        return 1
    fi

    # sh shell不支持type命令
    #if [ "$(type -t $1)" != "function" ]; then
    #    print_usage
    #    return 1
    #fi

    "$@"
}

main "$@"
