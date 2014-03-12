docker-znc
==========

ZNC bouncer container for Docker

Separate data container:

    docker run -v /home/znc/.znc --name DATA --entrypoint true elventear/znc
    
Application container, don't forget to specify a password for `admin` account.

    docker run -p 6667:6667 -p 113:113 -e ZNC_ADMIN_PASS=password -volumes-from DATA --name APP elventear/znc
