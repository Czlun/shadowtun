# Description
- Base on shadowsocks/shadowsocks-libev
- Integrated KCPTUN and shadowsocks-libev
- shadowtun [github](https://github.com/Czlun/shadowtun-docker)

## ENV list

### server

**common**

- SERVER_PORT

  以服务端启动时，覆盖8388作为shadowsocks监听的端口

- KCPTUN_ARG

  以任意模式启动时，为kcptun指定参数，默认值

  `"--mode fast3 --nocomp --dscp 46 --sockbuf 16777217 --sndwnd 4096 --rcvwnd 4096 "`



**shadowsocks**

- SS_SERVER_BIND

  shadowsocks服务端监听的ip，默认值`"0.0.0.0"`

- SS_SERVER_PORT

  shadowsocks服务端监听的port，默认值`"8388"`

- PASSWORD

  shadowsocks服务端设定的预共享密钥

- METHOD

  密钥的加密方式，默认值`"aes-256-gcm"`

- TIMEOUT

  超时时间，默认值`"300"`

- DNS_ADDRS

  远程dns地址，默认值`"8.8.8.8,8.8.4.4"`



**kcptun**

- KCPTUN_SERVER_BIND

  kcptun服务端监听的ip，默认值`"0.0.0.0"`

- KCPTUN_SERVER_PORT

  kcptun服务端监听的port，默认值`"4000"`

- KCPTUN_TARGETSVC_ADDR

  目标服务IP，默认值`"127.0.0.1"`

- KCPTUN_TARGETSVC_PORT

  目标服务端口，默认值`"${SS_SERVER_PORT}"`



### client

**common**

- SERVER_ADDR

  以客户端启动时，指定服务端的ip

- SERVER_PORT

  以客户端启动时，指定服务端的port

- KCPTUN_ARG

  以任意模式启动时，为kcptun指定参数，默认值`"--mode fast3 --nocomp --dscp 46 --sockbuf 16777217 --sndwnd 4096 --rcvwnd 4096 "`



**shadowsocks**

- SS_SERVER_ADDR

  shadowsocks服务端ip，由`SERVER_PORT`提供

- SS_LOCAL_BIND

  shadowsocks客户端监听的ip，默认值`"0.0.0.0"`

- SS_LOCAL_PORT

  shadowsocks客户端提供代理服务的端口，默认值`"1080"`

- PASSWORD

  shadowsocks服务端设定的预共享密钥

- METHOD

  密钥的加密方式，默认值"aes-256-gcm"

- TIMEOUT

  超时时间，默认值"300"

- DNS_ADDRS

  远程dns地址，默认值"8.8.8.8,8.8.4.4"

  

**kcptun**

- KCPTUN_SERVER_ADDR

  kcptun服务端ip，由`SERVER_PORT`提供

- KCPTUN_LOCAL_BIND

  kcptun客户端监听的ip，默认值`"0.0.0.0"`

- KCPTUN_LOCAL_PORT

  kcptun客户端监听的port，默认值`"4000"`



**privoxy**

- PRIVOXY_LOCAL_PORT

  privoxy客户端提供代理服务的端口，默认值`"2080"`



## run container

### server

- 暴露shadowsocks的服务端口和kcptun的服务端口

```bash
docker run -d \
-e PASSWORD=<YOUR PASSWORD> \
-p 18388:8388/tcp \
-p 18388:8388/udp \
-p 14000:4000/udp \
ahappysu/shadowtun server
```



### client

> 1080端口是socks5代理端口
>
> 2080端口是http代理端口



- 直接连接shadowsocks的服务端口

```bash
docker run -d \
-e PASSWORD=<YOUR PASSWORD> \
-e SERVER_ADDR=<SERVER IP>
-e SERVER_PORT=18388
-p 1080:1080/tcp \
-p 2080:2080/tcp \
ahappysu/shadowtun client ss
```



- 连接kcptun的服务端口

```bash
docker run -d \
-e PASSWORD=<YOUR PASSWORD> \
-e SERVER_ADDR=<SERVER IP>
-e SERVER_PORT=14000
-p 1080:1080/tcp \
-p 2080:2080/tcp \
ahappysu/shadowtun client kcptun
```



# Quick link

- shadowsocks/shadowsocks-libev [docker image](https://hub.docker.com/r/shadowsocks/shadowsocks-libev)
- shadowsocks/shadowsocks-libev [github](https://github.com/shadowsocks/shadowsocks-libev/tree/master/docker/alpine)
- kcptun [github](https://github.com/xtaci/kcptun)
