#!/usr/bin/env bash

# shellcheck disable=SC2154,SC2086
chia ${chia_args} start ${service}

trap "echo Shutting down ...; chia stop all -d; exit 0" SIGINT SIGTERM

# shellcheck disable=SC2154
if [[ ${log_to_file} == 'true' ]]; then
  # Ensures the log file actually exists, so we can tail successfully
  touch "$CHIA_ROOT/log/debug.log"
  tail -F "$CHIA_ROOT/log/debug.log" &
fi

sleep 10
if [[ -n ${self_hostname} ]]; then
  /usr/local/bin/chia-exporter serve --hostname ${self_hostname}  &
else
  /usr/local/bin/chia-exporter serve  &
fi

while true; do sleep 1; done
