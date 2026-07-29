#!/usr/bin/env bash

# PATH= # pure bash, no external programs

set -e

fetch_sysconfig() {
  local IMDS_IP=169.254.169.254

  exec {LINK_MON_FD}< <(ip monitor link address route)
  local LINK_MON_PID=$!

  until { exec {TCP_SOCK}<>/dev/tcp/$IMDS_IP/80; } 2>/dev/null; do
    if ! read -t 60 -r -u "$LINK_MON_FD" line; then
      echo ERROR: Timed out while waiting for network >&2
      exit 1
    fi
  done

  exec {LINK_MON_FD}>&-
  kill "$LINK_MON_PID"

  printf "%s\r\n" \
    "GET /hetzner/v1/metadata/network-sysconfig HTTP/1.1" \
    "Connection: close" \
    "Host: $IMDS_IP" \
    "" >&"$TCP_SOCK"

  shopt -s nocasematch

  content_len=0
  while true; do
    if ! IFS=$'\r\n' read -t 10 -r -u "$TCP_SOCK" line; then
      echo ERROR: Timed out or unexpected EOF on reading from TCP socket >&2
      exit 1
    fi
    if [[ -z $line ]]; then
      break
    fi
    if [[ $line =~ content-length:[[:space:]]*([0-9]+) ]]; then
      content_len="${BASH_REMATCH[1]}"
    fi
  done

  if ! read -r -t 10 -N "$content_len" -u "$TCP_SOCK" "$1"; then
    echo ERROR: Timed out or unexpected EOF on reading from TCP socket >&2
    exit 1
  fi

  exec {TCP_SOCK}>&-
}

gen_network_from_sysconfig() {
  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" =~ ^([A-Za-z0-9_]+)=(.*)$ ]]; then
      local key="${BASH_REMATCH[1]}"
      local value="${BASH_REMATCH[2]}"

      if [[ "$value" =~ ^\"(.*)\"$ ]] || [[ "$value" =~ ^\'(.*)\'$ ]]; then
        value="${BASH_REMATCH[1]}"
      fi

      local "$key"="$value"
    fi
  done

  if ! [[ -n $HWADDR && -n $IPV6ADDR && -n $IPV6_DEFAULTGW ]]; then
    echo ERROR: One of the requried variables was empty >&2
    echo "HWADDR=$HWADDR" >&2
    echo "IPV6ADDR=$IPV6ADDR" >&2
    echo "IPV6_DEFAULTGW=$IPV6_DEFAULTGW" >&2
    exit 1
  fi

  printf "%s\n" \
    "[Match]" \
    "MACAddress=$HWADDR" \
    "" \
    "[Network]" \
    "DHCP=ipv4" \
    "" \
    "[DHCPv4]" \
    "UseDNS=no" \
    "" \
    "[Address]" \
    "Address=$IPV6ADDR" \
    "" \
    "[Route]" \
    "Gateway=${IPV6_DEFAULTGW%%\%*}" \
    "GatewayOnLink=yes"
}

main() {
  local response_body=
  fetch_sysconfig response_body
  if [[ -z $response_body ]]; then
    echo ERROR: Response was empty for some reason >&2
    exit 1
  fi
  gen_network_from_sysconfig <<<"$response_body" \
    > /etc/systemd/network/20-hetzner-imds-eth.network
}

main

