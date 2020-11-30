FROM shadowsocks/shadowsocks-libev:latest 

MAINTAINER Czlun <weiwenbin@czlun.com>

USER root

#common
ENV SERVER_ADDR=""
ENV SERVER_PORT=""

#ss-common
ENV PASSWORD=""
ENV METHOD="aes-256-gcm"
ENV TIMEOUT="300"
ENV DNS_ADDRS="8.8.8.8,8.8.4.4"

#kcptun-common
ENV KCPTUN_ARG="--mode fast3 --nocomp --dscp 46 --sockbuf 16777217 --sndwnd 4096 --rcvwnd 4096 "

#ss-server
ENV SS_SERVER_BIND="0.0.0.0"
ENV SS_SERVER_PORT=""

#kcptun-server
ENV KCPTUN_SERVER_BIND="0.0.0.0"
ENV KCPTUN_SERVER_PORT="4000"
ENV KCPTUN_TARGETSVC_ADDR="127.0.0.1"
ENV KCPTUN_TARGETSVC_PORT=""

#ss-local
ENV SS_SERVER_ADDR=""
ENV SS_LOCAL_BIND="0.0.0.0"
ENV SS_LOCAL_PORT="1080"

#kcptun-local
ENV KCPTUN_SERVER_ADDR=""
ENV KCPTUN_LOCAL_BIND="0.0.0.0"
ENV KCPTUN_LOCAL_PORT="4000"

#privoxy-local
ENV PRIVOXY_LOCAL_PORT="2080"

COPY ./client_linux_amd64 ./server_linux_amd64 ./entrypoint.sh /tmp/repo/

RUN set -ex \
 && apk add --no-cache curl privoxy \
 && chown -R nobody:nobody /etc/privoxy/

RUN set -ex \
 && ls -l /tmp/repo \
 && mv /tmp/repo/entrypoint.sh /tmp/repo/client_linux_amd64 /tmp/repo/server_linux_amd64 /usr/bin/ \
 && rm -rf /tmp/repo

USER nobody

ENTRYPOINT ["sh", "/usr/bin/entrypoint.sh"]
