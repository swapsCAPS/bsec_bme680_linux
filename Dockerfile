FROM balenalib/raspberrypi3-python:3.8-build

WORKDIR /usr/bin/app

COPY prom_exporter.py prom_exporter.py
COPY src src
COPY patches patches
COPY bsec_bme680.c bsec_bme680.c
COPY make.config make.config
COPY make.sh make.sh

RUN apt update && apt install -y libgmp3-dev

RUN pip install prometheus_client

RUN ./make.sh

ENTRYPOINT [ "python", "/usr/bin/app/prom_exporter.py" ]
