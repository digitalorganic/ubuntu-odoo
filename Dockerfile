FROM digitalorganic/ubuntu-python:2004.2718

LABEL MAINTAINER="Digital Organic Co.,Ltd. <docker@do.co.th>"

# odoo 6.1 still use local server time

ENV TZ=Asia/Bangkok

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone


RUN groupadd -r odoo && useradd -r -g odoo odoo


RUN apt-get update && apt-get install -y --no-install-recommends \
    curl gdebi npm node-less \
    libxslt1-dev libxml2-dev libxslt-dev \
    libpq-dev libsasl2-dev python-dev libldap2-dev libssl-dev\
    libtiff5-dev libjpeg8-dev libopenjp2-7-dev zlib1g-dev \
    libfreetype6-dev liblcms2-dev libwebp-dev tcl8.6-dev tk8.6-dev python3-tk \
    libharfbuzz-dev libfribidi-dev libxcb1-dev openjdk-8-jdk poppler-utils ghostscript ldap-utils

RUN echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula \
    select true | debconf-set-selections
RUN apt-get install --no-install-recommends -y -q \
    ttf-mscorefonts-installer  ttf-dejavu-core fonts-thai-tlwg 

# extra lib for odbc
ENV DRIVER_VERSION=1.5.4.1002
RUN apt-get update && apt-get install -y --no-install-recommends alien unixodbc unixodbc-dev &&\
    wget "https://fileserv.do.co.th/static/files/dremio/2022/dremio-odbc-${DRIVER_VERSION}-1.x86_64.rpm" -O /dremio-odbc-${DRIVER_VERSION}-1.x86_64.rpm &&\
    alien -i --scripts /dremio-odbc-${DRIVER_VERSION}-1.x86_64.rpm &&\
    rm -f /dremio-odbc-${DRIVER_VERSION}-1.x86_64.rpm

WORKDIR /odoo
ADD requirements.txt /odoo/requirements.txt
RUN easy_install egenix-mx-base && pip install --upgrade pip && pip install -r /odoo/requirements.txt
