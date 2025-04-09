#!/bin/bash

# Solaris/Linux HP StartArray components status script

ctrl_slot=0

MAX_ATTEMPTS=3
SLEEP_INTERVAL=5
attempt=0

PREFIX=""
PREFIX_HPACUCLI=""
PRIV_EXEC=""

if [ "`uname`" = "SunOS" ]; then
  PREFIX="/opt/csw/gnu"
  PREFIX_HPACUCLI="/opt/HPQacucli/sbin"
  PRIV_EXEC="/bin/pfexec"
elif [ "`uname`" = "Linux" ]; then
  PREFIX="/usr/bin"
  PREFIX_HPACUCLI="/usr/sbin"
  PRIV_EXEC=$PREFIX"/sudo"
fi

# Utilities
ECHO=$PREFIX"/echo"
GREP=$PREFIX"/grep"
WC=$PREFIX"/wc"
HPACUCLI=$PREFIX_HPACUCLI"/hpacucli"

cmd2exec=""
filter=""

# Arg processing
case $1 in
  raid|RAID) cmd2exec="ctrl slot=$ctrl_slot pd all show status"
             filter="physicaldrive"
  ;;
  ctrl|CTRL) cmd2exec="ctrl slot=$ctrl_slot show status"
             filter="Controller"
  ;;
  cache|CACHE) cmd2exec="ctrl slot=$ctrl_slot show status"
             filter="Cache"
  ;;
  battery|BATTERY) cmd2exec="ctrl slot=$ctrl_slot show status"
             filter="Battery"
  ;;
  *) $ECHO "Wrong $1 value: Only raid, ctrl, cache or battery values acceptable."
             exit 1
  ;;
esac

while (( attempt < MAX_ATTEMPTS )); do
  # Execute command
  output=$($PRIV_EXEC $HPACUCLI $cmd2exec 2>&1)
  # Check if hpacucli is already running
  echo "$output" | $GREP "Another instance of hpacucli is running" > /dev/null
  if [ $? -eq 0 ]; then
    # If the process is already running, just wait and try again.
    sleep $SLEEP_INTERVAL
  else
    # If the command is successful, we filter and return the number of rows
    count=$($ECHO "$output" | $GREP $filter | $GREP -v -e '^$' -e 'OK$' | $WC -l)
    # If nothing is found, return 0
    if [ -z "$count" ]; then
      count=0
    fi
    $ECHO "$count"
    exit 0
  fi

  ((attempt++))
done

# If the command could not be executed beyond MAX_ATTEMPTS
$ECHO "0"
exit 1
