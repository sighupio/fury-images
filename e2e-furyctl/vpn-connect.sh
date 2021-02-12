#!/bin/bash

OVPN_PROFILE=$1

if [ ! -f "$OVPN_PROFILE" ]; then
  echo "ERROR: $OVPN_PROFILE does not exist."
  exit 1
fi

# If the container can add a new net interface, means it runs as privileged
# source: https://stackoverflow.com/questions/32144575/how-to-know-if-a-docker-container-is-running-in-privileged-mode
ip link add dummy0 type dummy >/dev/null
if [ $? -eq 0 ]; then
  # clean the dummy0 link
  ip link delete dummy0 >/dev/null
else
  # if not, check if it has the NET_ADMIN capability is enabled.
  capsh --print | grep "Current:" | cut -d' ' -f3 | grep -q cap_net_admin
  if [ $? -eq 1 ]; then
    echo "ERROR: Ensure you are running the container using --cap-add=NET_ADMIN or --privileged"
    exit 1
  fi
fi

mkdir -p /dev/net
ls /dev/net/tun >/dev/null 2>&1
RESULT=$?
if [ $RESULT -ne 0 ]; then
  mknod /dev/net/tun c 10 200
  chmod 600 /dev/net/tun
fi
openvpn --config $OVPN_PROFILE --daemon
