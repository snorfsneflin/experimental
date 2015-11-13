
# generate new ssh keys
if [ -d ${HOME}/.ssh ];
  then
    cd ${HOME}/.ssh && ssh-keygen -t ed25519 -o -a 100
    cd ${HOME}/.ssh && ssh-keygen -t rsa -b 4096 -o -a 100

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

