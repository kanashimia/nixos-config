#!/usr/bin/env bash

set -e

SCOPE="app-$(systemd-escape -- "$(basename "$1")")-$RANDOM"

exec systemd-run --user --scope --quiet --no-ask-password -u "$SCOPE" -- systemd-cat -- "$@"
