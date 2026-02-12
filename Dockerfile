FROM balenalib/raspberrypi3-python:3.8-build AS build

WORKDIR /usr/bin/app

COPY src src
COPY patches patches
COPY bsec_bme680.c bsec_bme680.c
COPY make.config make.config
COPY make.sh make.sh

RUN apt update && apt install -y libgmp3-dev

RUN ./make.sh

FROM balenalib/raspberrypi3-python:3.8

WORKDIR /usr/bin/app

RUN pip install prometheus_client

COPY --from=build /usr/bin/app/bsec_bme680 .
COPY prom-exporter.py .

ENTRYPOINT [ "python", "/usr/bin/app/prom-exporter.py" ]
