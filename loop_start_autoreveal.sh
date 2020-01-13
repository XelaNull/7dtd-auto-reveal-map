#!/bin/bash
export INSTALL_DIR=/data/7DTD
# If this script is already running, then exit
PIDTEST=`/usr/sbin/pidof -o %PPID -x "loop_start_autoreveal.sh"`
if [[ $PIDTEST != "" ]]; then exit; fi
# Loop until the 7dtd server initialization completes
while true; do
  if [ -f /7dtd.initialized ]; then break; fi; sleep 6;
done
# Loop forever
while true; do
  if [[ -f $INSTALL_DIR/7DaysToDieServer.x86_64 ]] && [[ `cat $INSTALL_DIR/auto-reveal.status` == "start" ]]; then
    SERVER_PID=`ps awwux | grep -v grep | grep 7DaysToDieServer.x86_64`;
    [[ ! -z $SERVER_PID ]] && /data/7DTD/7dtd-auto-reveal-map/7dtd-run-after-initial-start.sh /data/7DTD
  fi
  sleep 2
done