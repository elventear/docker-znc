FROM elventear/supervisord:latest 

MAINTAINER Pepe Barbe dev@antropoide.net


RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y software-properties-common

RUN add-apt-repository -y ppa:teward/znc && \
    apt-get update && \
    apt-get install -y znc znc-dev curl oidentd && \
    useradd -m znc

WORKDIR /home/znc

# http://wiki.znc.in/Identfile
# http://colloquy.info/project/wiki/PushNotifications
# https://github.com/shykes/docker-znc/blob/master/zncrun

ADD files/znc /home/znc

RUN curl -L http://github.com/wired/colloquypush/raw/master/znc/colloquy.cpp > colloquy.cpp && \
    znc-buildmod colloquy.cpp && \
    mv -v colloquy.so /home/znc/.znc/modules && \
    rm colloquy.cpp && \
    znc -p -d /home/znc/.znc && \
    echo 'user "znc" { \
    default { \
        allow spoof \
        allow spoof_all \
        allow spoof_privport \
        allow random \
        allow random_numeric \
        allow numeric \
        allow hide \
    } \
}' >> /etc/oidentd.conf && \
    chmod 644 /home/znc/.oidentd.conf && chmod 711 /home/znc && chown -R znc:znc /home/znc

ADD files/supervisord/oident.conf /etc/supervisor/conf.d/oident.conf
ADD files/supervisord/znc.conf /etc/supervisor/conf.d/znc.conf

VOLUME ["/home/znc/.znc"]
EXPOSE 6667
EXPOSE 113

CMD ["/usr/bin/supervisord"]
