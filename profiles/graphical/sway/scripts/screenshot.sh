#!/usr/bin/env bash
# swaymsg -t get_outputs | jq -r '.[]|select(has("focused")) | [.name, .rect.x, .rect.y, .rect.width, .rect.height] | @sh'

OUTPUT=eDP-1
WIDTH=1920 
HEIGHT=1080
SCALE=3

swaymsg -t get_outputs | jq -r '.[].name | select(startswith("HEADLESS-"))' | while read OUT; do
  swaymsg output "$OUT" unplug
done
  
swaymsg create_output

FAKEOUT=$(swaymsg -t get_outputs | jq -r '.[].name | select(startswith("HEADLESS-"))')

XYWH="$(slurp)"

swaymsg output "$FAKEOUT" resolution "$((WIDTH * SCALE))"x"$((HEIGHT * SCALE))"
swaymsg output "$FAKEOUT" scale "$SCALE"
swaymsg output "$FAKEOUT" pos 0 0

swaymsg move workspace to "$FAKEOUT"
swaymsg focus output "$FAKEOUT"

sleep 1

grim -g "$XYWH" - | wl-copy

swaymsg move workspace to "$OUTPUT"
swaymsg focus output "$OUTPUT"

swaymsg output "$FAKEOUT" unplug
