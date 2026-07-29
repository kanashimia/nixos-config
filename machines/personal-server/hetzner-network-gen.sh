#!/usr/bin/env bash

set -e

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
    "GatewayOnLink=yes" \
    > /etc/systemd/network/20-hetzner-imds-eth.network
}

systemd-imds /network-sysconfig | gen_network_from_sysconfig
