#!/bin/bash
stress-ng --cpu ${CPUS} --vm ${WORKER} --vm-bytes ${MEMORY} --timeout ${TIMEOUT}  -v --metrics-brief