FROM balenalib/raspberrypi3-python:3.8-build

WORKDIR /usr/bin/app

COPY include include
COPY lib lib
COPY third_party third_party
COPY src src
COPY patches patches
COPY bsec_bme680.c bsec_bme680.c
COPY make.config make.config
COPY make.sh make.sh

RUN apt update && apt install -y build-essential libmicrohttpd-dev gnutls-dev file

RUN ./make.sh
