import subprocess
import threading
import io
import time
import os
from prometheus_client import Gauge, start_http_server

data_types = [
    "time",
    "iaq_accuracy",
    "iaq",
    "temperature",
    "humidity",
    "pressure",
    "gas",
    "bsec_status",
    "co2_equivalent",
    "breath_voc_equivalent",
]


class PrometheusExporter:
    def __init__(self):
        self.command = os.environ.get("BSEC_BME680_CMD", "./bsec_bme680")
        self.port = int(os.environ.get("PORT", "4242"))

        gauge = Gauge("bme680_metrics", "bme680_metrics", ["type"])

        print(f"Initialized with bsec_bme680 location: {self.command}")
        print(f"Initialized with prom server port: {self.port}")

    def start(self):
        print("Starting capture thread")
        self.capture_thread = threading.Thread(target=self.capturewrap)
        self.capture_thread.start()

        print(f"Starting server at port {self.port}")
        start_http_server(self.port)

    def capturewrap(self):
        while True:
            try:
                self.capture()
            except BaseException as e:
                print("{!r}; restarting capture thread".format(e))
            else:
                print("Capture thread exited; restarting")
            time.sleep(5)

    def capture(self):
        process = subprocess.Popen([self.command], stdout=subprocess.PIPE)

        for line in io.TextIOWrapper(process.stdout, encoding="utf-8"):
            data = line.strip()
            print(data)
            if not data.startswith("_data"):
                continue

            data.split(",")
            data.pop(0)

            for type, value in zip(data_types, data):
                gauge.labels(type=type).set(value)

        rc = process.poll()
        time.sleep(2)
        return rc


PrometheusExporter().start()
