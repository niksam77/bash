#!/bin/bash

haproxy_link="http://www.haproxy.org/download/2.2/src/haproxy-2.2.13.tar.gz"

archive="haproxy-2.2.13.tar.gz"

namedir="/opt/haproxy-2.2.13"




dnf install gcc pcre-devel make openssl-devel systemd-devel -y

wget -P /opt $haproxy_link

tar -xvf /opt/$archive && \
cd $namedir             && \
make clean               && \
make -j $(nproc) TARGET=linux-glibc \
                USE_OPENSSL=1 USE_ZLIB=1 USE_LUA=1 USE_PCRE=1 USE_SYSTEMD=1 && \
make install

mkdir -p /etc/haproxy 
mkdir -p /var/lib/haproxy 
touch /var/lib/haproxy/stats

ln -s /usr/local/sbin/haproxy /usr/sbin/haproxy

cp $namedir/examples/haproxy.init /etc/init.d/haproxy

chmod 755 /etc/init.d/haproxy

systemctl daemon-reload

chkconfig haproxy on

useradd -r haproxy

cat <<EOF > /etc/haproxy/haproxy.cfg
global
   log /dev/log local0
   log /dev/log local1 notice
   chroot /var/lib/haproxy
   stats timeout 30s
   user haproxy
   group haproxy
   daemon

defaults
   log global
   mode http
   option httplog
   option dontlognull
   timeout connect 5000
   timeout client 50000
   timeout server 50000

frontend http_front
   bind *:80
   stats uri /haproxy?stats
   default_backend http_back

backend http_back
   balance roundrobin
   server server_name1 private_ip1:80 check
   server server_name2 private_ip2:80 check
EOF

systemctl restart haproxy






