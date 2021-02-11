#!/bin/bash

OVPN_PROFILE=$1

if [ ! -f "$OVPN_PROFILE" ]; then
  echo "ERROR: $OVPN_PROFILE does not exist."
  exit 1
fi

capsh --print | grep "Current:" | cut -d' ' -f3 | grep -q cap_net_admin
RESULT=$?
if [ $RESULT -eq 1 ]; then
  echo "ERROR: Ensure you are running the container using --cap-add=NET_ADMIN"
  exit 1
fi

mkdir -p /dev/net
ls /dev/net/tun > /dev/null 2>&1
RESULT=$?
if [ $RESULT -ne 0 ]; then
  mknod /dev/net/tun c 10 200
  chmod 600 /dev/net/tun
fi
openvpn --config $OVPN_PROFILE --daemon
