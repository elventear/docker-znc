FROM ubuntu:13.10

MAINTAINER Pepe Barbe dev@antropoide.net

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y software-properties-common

RUN add-apt-repository -y ppa:teward/znc && \
    apt-get update && \
    apt-get install -y znc znc-dev curl && \
    useradd -m znc

WORKDIR /home/znc

# http://wiki.znc.in/Identfile
# http://colloquy.info/project/wiki/PushNotifications
# https://github.com/shykes/docker-znc/blob/master/zncrun
# http://wiki.znc.in/Using_ident_spoofs_with_identserver_and_iptables

ADD files/znc_home /home/znc

RUN curl -L https://raw.github.com/wired/colloquypush/master/znc/colloquy.cpp > colloquy.cpp && \
        znc-buildmod colloquy.cpp && \
        mv -v colloquy.so /home/znc/.znc/modules && \
        rm colloquy.cpp && \
    curl -L https://raw.github.com/KiNgMaR/znc/msvc/win32/extra_modules/identserver.cpp > identserver.cpp && \
        export export CXXFLAGS='-std=c++11' && \
        znc-buildmod identserver.cpp && \
        mv -v identserver.so /home/znc/.znc/modules && \
        rm identserver.cpp && \
    chmod 711 /home/znc && chown -R znc:znc /home/znc

VOLUME ["/home/znc/.znc"]

EXPOSE 6667
EXPOSE 113

USER znc

CMD ["/home/znc/run_znc.sh"]
