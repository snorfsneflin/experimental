#!/bin/sh

#check for presence of /dev/random
if [ -f /dev/random ]; 
  then
    echo '/dev/random exists' 

  else
    echo '/dev/random is not present'

fi

# ipv6
echo 'applications using ipv6'
echo
netstat -tulpn | grep ::
  
#disable ipv6 on linux
if [ "$(cat /proc/sys/net/ipv6/conf/all/disable_ipv6)" -eq '0' ]; then
  echo 'net.ipv6.conf.all.disable_ipv6=1' >> /etc/sysctl.conf
  echo 'net.ipv6.conf.default.disable_ipv6=1' >> /etc/sysctl.conf
  echo 'net.ipv6.conf.lo.disable_ipv6=1' >> /etc/sysctl.conf
  sysctl -p
fi

#disable ipv6 usage in ssh
if [ -f /etc/default/ssh ]; then
echo 'disable ipv6 from being used in ssh - comment out and restart sshd to enable'
echo 'SSHD_OPTS="-4"' >> /etc/default/ssh
fi

#disable ipv6 in avahi
if [ -f /etc/avahi/avahi-daemon.conf ]; then
echo 'disable ipv6 from being used by avahi'
sed -n 's/use-ipv6=yes/use-ipv6=no' /etc/avahi/avahi-daemon.conf
fi

#disable ipv6 on dhclient for dhcp requests
#/etc/dhcp/dhclient.conf

#disable ipv6 in java
#/etc/java-7-openjdk/net.properties
#http.nonProxyHosts=localhost|127.*
#ftp.nonProxyHosts=localhost|127.*

# restart services to complete disabling ipv6
service sshd restart
service tomcat7 restart
service avahi-daemon restart

# generate new ssh keys
if [ -d ${HOME}/.ssh ];
  then
    cd ${HOME}/.ssh && ssh-keygen -t ed25519 -o -a 100
    cd ${HOME}/.ssh && ssh-keygen -t rsa -b 4096 -o -a 100
fi

#clean up existing keys, then roll new ones
if [ -d /etc/ssh ];
  then
    rm /etc/ssh/ssh_host_*key*
    cd /etc/ssh && ssh-keygen -t ed25519 -f ssh_host_ed25519_key < /dev/null 
    cd /etc/ssh && ssh-keygen -t rsa -b 4096 -f ssh_host_rsa_key < /dev/null
  else
    echo '/etc/ssh doesn't exist ... '
    echo 'creating ... '
    mkdir -p -m 0755 /etc/ssh
fi

if [ -f /etc/ssh/moduli ]; 
  then
    echo 'removing version 1 encryption'
    echo
    awk '$5 > 2000' /etc/ssh/moduli > "${HOME}/moduli.tmp"
    echo 'number of lines left:'
    wc -l "${HOME}/moduli.tmp"
    mv "${HOME}/moduli.tmp" /etc/ssh/moduli
  else
    echo 'moduli file not present, creating ... '
    echo
    ssh-keygen -G /etc/ssh/moduli.all -b 4096
    ssh-keygen -T /etc/ssh/moduli.safe -f /etc/ssh/moduli.all
    echo '...'
    mv /etc/ssh/moduli.safe /etc/ssh/moduli
    rm /etc/ssh/moduli.all
    echo
    echo 'moduli file built'
fi

