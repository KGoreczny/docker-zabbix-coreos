FROM debian:jessie
MAINTAINER Boris HUISGEN <bhuisgen@hbis.fr>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get -y install locales && \
    dpkg-reconfigure locales && \
    locale-gen C.UTF-8 && \
    /usr/sbin/update-locale LANG=C.UTF-8 && \
    echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen && \
    locale-gen
ENV LC_ALL C.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV TERM xterm

RUN apt-get update && \
    apt-get -y install \
        ucf \
        procps \
        iproute \
        supervisor
COPY etc/supervisor/ /etc/supervisor/

RUN apt-get update && \
    apt-get -y install --no-install-recommends \
        curl \
        jq \
        libcurl3-gnutls \
        libldap-2.4-2 \
        netcat-openbsd \
        pciutils \
        sudo

RUN \
  curl -O http://repo.zabbix.com/zabbix/3.0/debian/pool/main/z/zabbix-release/zabbix-release_3.0-1+jessie_all.deb && \
  dpkg -i zabbix-release_3.0-1+jessie_all.deb && \
  apt-get update && \
  apt-get install -y zabbix-agent

COPY etc/zabbix/ /etc/zabbix/

RUN mkdir -p /var/lib/zabbix && \
    chmod 700 /var/lib/zabbix && \
    chown zabbix:zabbix /var/lib/zabbix && \
    usermod -d /var/lib/zabbix zabbix && \
    usermod -a -G adm zabbix

COPY etc/sudoers.d/zabbix etc/sudoers.d/zabbix
RUN chmod 400 /etc/sudoers.d/zabbix

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY run.sh /
RUN chmod +x /run.sh

EXPOSE 10050
ENTRYPOINT ["/run.sh"]
CMD [""]
