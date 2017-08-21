FROM gaomd/ikev2-vpn-server

ADD entrypoint.sh /usr/local/bin
ENTRYPOINT ["entrypoint.sh"]
