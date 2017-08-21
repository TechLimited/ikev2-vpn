FROM gaomd/ikev2-vpn-server

ENV VOLUME "/opt/ikev2"
VOLUME $VOLUME

ADD entrypoint.sh /usr/local/bin
ENTRYPOINT ["entrypoint.sh"]
CMD ["/usr/sbin/ipsec", "start", "--nofork"]
