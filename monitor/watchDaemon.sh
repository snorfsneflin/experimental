#!/bin/sh

# check that daemons are performing
# todo - limit starts, check for dumps, some services don't use 'status'

# daemons to keep an eye on:
declare -r watch='sshd|ntpd|cron'

while read daemon
do
  if [ service ${daemon} status ]
    then
      :
    else
      echo "$daemon is NOT running"
      echo "restarting $daemon now"
      ${daemon} start
      
  fi
done < <(service -e | egrep "$watch")
