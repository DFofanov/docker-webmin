# Использование последней версии сервра Ubuntu
FROM ubuntu:focal
MAINTAINER "Dmitry Fofanov" <dfofanov@gmail.com>

ENV DEBIAN_FRONTEND=noninteractive TZ=Europe/Moscow

# Обновление ядра и установка утилит
RUN apt-get update -qq -y && \
    apt-get upgrade -y && \
    apt-get install -y \
       wget \
       curl \
       apt-transport-https \
       lsb-release \
       ca-certificates \
       gnupg2 \
       software-properties-common \
       locales \
       cron    
RUN dpkg-reconfigure locales

# Установка Webmin
RUN echo root:password | chpasswd && \
    echo "Acquire::GzipIndexes \"false\"; Acquire::CompressionTypes::Order:: \"gz\";" >/etc/apt/apt.conf.d/docker-gzip-indexes && \
    update-locale LANG=C.UTF-8 && \
    echo deb https://download.webmin.com/download/repository sarge contrib >> /etc/apt/sources.list && \
    wget http://www.webmin.com/jcameron-key.asc && \
    apt-key add jcameron-key.asc && \
    apt-get update && \
    apt-get install -y webmin && \
    apt-get clean

EXPOSE 8000
ENV LC_ALL ru_RU.UTF-8

WORKDIR /home
RUN echo "#! /bin/bash" > entrypoint.sh && \
    echo "sed -i 's;ssl=1;ssl=0;' /etc/webmin/miniserv.conf && systemctl enable cron && service webmin start && tail -f /dev/null" >> entrypoint.sh && \
    chmod 755 entrypoint.sh

CMD /home/entrypoint.sh