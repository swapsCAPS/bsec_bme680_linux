#!/bin/sh

#set -x
set  -eu

. ./make.config

if [ ! -d "${BSEC_DIR}" ]; then
  echo 'BSEC directory missing.'
  exit 1
fi

if [ ! -d "${CONFIG_DIR}" ]; then
  mkdir "${CONFIG_DIR}"
fi

STATEFILE="${CONFIG_DIR}/bsec_iaq.state"
if [ ! -f "${STATEFILE}" ]; then
  touch "${STATEFILE}"
fi

echo 'Patching...'
dir="${BSEC_DIR}/examples/bsec_iot_example"
patch='patches/eCO2+bVOCe.diff'
if patch -N --dry-run --silent -d "${dir}/" \
  < "${patch}" 2>/dev/null
then
  patch -d "${dir}/" < "${patch}"
else
  echo 'Already applied.'
fi

EXAMPLES_DIR="${BSEC_DIR}/examples/bsec_iot_example"

echo ldconfig:
ldconfig -p | grep libmicrohttpd
file /usr/lib/arm-linux-gnueabihf/libmicrohttpd.so

echo 'Compiling...'
gcc -Wall -Wno-unused-but-set-variable -Wno-unused-variable -static \
  -std=gnu99 -pedantic \
  -iquote"${BSEC_DIR}"/algo/${ARCH} \
  -iquote"${EXAMPLES_DIR}" \
  -Ithird_party/prometheus-client-c/prom/include \
  -Ithird_party/prometheus-client-c/promhttp/include \
  "${EXAMPLES_DIR}"/bme680.c \
  "${EXAMPLES_DIR}"/bsec_integration.c \
  -lmicrohttpd \
  third_party/prometheus-client-c/promhttp/src/*.c \
  third_party/prometheus-client-c/prom/src/*.c \
  -L"${BSEC_DIR}"/algo/"${ARCH}" \
  -lalgobsec \
  -lpthread \
  -lgnutls \
  ./bsec_bme680.c \
  -lm \
  -lrt \
  -lgmp \
  -o bsec_bme680 \
  -Wl,-v
echo 'Compiled.'

cp "${BSEC_DIR}"/config/"${CONFIG}"/bsec_iaq.config "${CONFIG_DIR}"/
echo 'Copied config.'

