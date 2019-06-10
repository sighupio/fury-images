#!/usr/bin/env python

from prometheus_client import Counter, start_http_server

import time

TRANSACTION_COUNTER = Counter('transaction_count', 'Transactions processed')

def request(count):
    global TRANSACTION_COUNTER

    TRANSACTION_COUNTER.inc()

    if count % 1000 == 0:
        time.sleep(600)
    else:
        time.sleep(0.01)


if __name__ == '__main__':
    start_http_server(8000)

    count = 0
    while True:
        count += 1
        request(count)
