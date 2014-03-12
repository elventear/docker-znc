docker-znc
==========

ZNC bouncer container for Docker

Separate data container:

    docker run -v /home/znc/.znc --name DATA --entrypoint true elventear/znc
    
Application container, don't forget to specify a password for `admin` account.

    docker run -p 6667:6667 -p 127.0.0.1:11300:11300 -e ZNC_ADMIN_PASS=password -volumes-from DATA --name APP elventear/znc

Finally, forward IDENT queries to the IDENT server in ZNC:
    
     iptables -t nat -A PREROUTING -p tcp -i eth0 --dport 113 -j DNAT --to 127.0.0.1:11300
