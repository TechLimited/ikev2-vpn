#!/bin/bash
[ "no${HOST}" = "no" ] && echo "\$HOST environment variable required." && exit 1

mkdir -p $VOLUME
cd $VOLUME

sysctl net.ipv4.ip_forward=1
sysctl net.ipv6.conf.all.forwarding=1
sysctl net.ipv6.conf.eth0.proxy_ndp=1
iptables -t nat -A POSTROUTING -s 10.8.0.0/16 -o eth0 -m policy --dir out --pol ipsec -j ACCEPT
iptables -t nat -A POSTROUTING -s 10.8.0.0/16 -o eth0 -j MASQUERADE
ip6tables -t nat -A POSTROUTING -s fd6a:6ce3:c8d8:7caa::/64 -o eth0 -m policy --dir out --pol ipsec -j ACCEPT
ip6tables -t nat -A POSTROUTING -s fd6a:6ce3:c8d8:7caa::/64 -o eth0 -j MASQUERADE

# hotfix for openssl `unable to write 'random state'` stderr
if [ ! -f ${VOLUME}/ipsec.secrets ]; then
  echo "Generate new secrets ..."
  SHARED_SECRET="123$(openssl rand -base64 32 2>/dev/null)"
  echo ": PSK \"${SHARED_SECRET}\"" > ${VOLUME}/ipsec.secrets
fi

cat ${VOLUME}/ipsec.secrets > /etc/ipsec.secrets

# hotfix for https://github.com/gaomd/docker-ikev2-vpn-server/issues/7
rm -f /var/run/starter.charon.pid

service ndppd start
# http://wiki.loopop.net/doku.php?id=server:vpn:strongswanonopenvz

if [ ! -f "${HOST}.mobileconfig" ]; then
  generate-mobileconfig > "${HOST}".mobileconfig
fi

exec "$@"
