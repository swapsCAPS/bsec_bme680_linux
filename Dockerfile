FROM balenalib/raspberrypi3-python:3.8-build

WORKDIR /usr/bin/app

COPY src src
COPY patches patches
COPY bsec_bme680.c bsec_bme680.c
COPY make.config make.config
COPY make.sh make.sh

RUN apt update && apt install -y libgmp3-dev

RUN ./make.sh

ENTRYPOINT [ "/usr/bin/app/bsec_bme680" ]
