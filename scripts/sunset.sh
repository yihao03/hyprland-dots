#!/usr/bin/env bash

set_sunset() {
  hour=$(date +%H)
  minute=$(date +%M)
  hour=$((10#$hour))
  minute=$((10#$minute))
  time_minutes=$((hour * 60 + minute))
  sunrise=$((7 * 60 + 30)) # 7:30
  sunset=$((18 * 60))      # 18:00

  if [ "$time_minutes" -ge "$sunrise" ] && [ "$time_minutes" -lt "$sunset" ]; then
    hyprctl hyprsunset identity
  else
    hyprctl hyprsunset temperature 4000
  fi
}

set_sunset
