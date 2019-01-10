#!/bin/bash
# Run some action. Log its output.
action() {
  local STRING rc

  STRING=$1
  echo -n "$STRING "
  shift
  "$@" && success $"$STRING" || failure $"$STRING"
  rc=$?
  echo
  return $rc
}

if [ ! -f /etc/rsyncd.conf ]
    then
    action "rsync配置" /bin/false
    exit 1
elif [ ! -f /usr/bin/rsync ]
    then
    action "rsync命令" /bin/false
    exit 1
fi



