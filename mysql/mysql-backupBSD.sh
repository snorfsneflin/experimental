    #!/bin/sh
    # A Shell script to backup all MySQL databases to a NAS server mounted via mount_smbfs
    # You need to setup username, password and other stuff
    # Tested on FreeBSD 6.x and 7.x - 32 bit and 64 bit systems.
    # May work on OpenBSD / NetBSD.
    # -------------------------------------------------------------------------
    # Copyright (c) 2007 nixCraft project <http://www.cyberciti.biz/fb/>
    # This script is licensed under GNU GPL version 2.0 or above
    # -------------------------------------------------------------------------
    # This script is part of nixCraft shell script collection (NSSC)
    # Visit http://bash.cyberciti.biz/ for more information.
    # ----------------------------------------------------------------------
    ### SETUP BIN PATHS ###
    MYSQLADMIN=/usr/local/bin/mysqladmin
    MYSQL=/usr/local/bin/mysql
    LOGGER=/usr/bin/logger
    MYSQLDUMP=/usr/local/bin/mysqldump
    MKDIR=/bin/mkdir
    CP=/bin/cp
    GZIP=/usr/bin/gzip
    CUT=/usr/bin/cut
    AWK=/usr/bin/awk
    MOUNT=/sbin/mount
    GREP=/usr/bin/grep
    UMOUNT=/sbin/umount
    MSMBFS=/usr/sbin/mount_smbfs
    HOST=/usr/bin/host
    TAIL=/usr/bin/tail
    SSH=/usr/bin/ssh
    SCP=/usr/bin/scp
    HOSTNAME=/bin/hostname
     
    ### SETUP MYSQL LOGIN ###
    MUSER=root
    MPASS='PASSWORD'
    MHOST="127.0.0.1"
     
    ### SETUP NAS LOGIN ###
    NASUSER=vivek
    NASPASSWORD=myPassword
    NASSERVER=nas05.vip.nixcraft.com
    NASMNT=/nas05
    NASSHARE=$NASUSER
    NASPASSWDFILE=$HOME/.nsmbrc
    #GET NAS IP
    NASIP=$($HOST $NASSERVER  | $TAIL -1 | $AWK '{ print $4}')
    # NAS BACKUP PATH
    MBAKPATH=${NASMNT}/$(hostname -s)/mysql
    NOW=$(date +"%d-%m-%Y")
    TIME_FORMAT='%H_%M_%S%P'
     
    mount_nas(){
    	[ ! -d $NASMNT ] && $MKDIR -p $NASMNT
    	$MOUNT | $GREP $NASMNT >/dev/null
    	if [ $? -ne 0 ]
    	then
    		echo "[$NASIP:$NASUSER]"  >$NASPASSWDFILE
    		echo "password=$NASPASSWORD" >>$NASPASSWDFILE
    		$MSMBFS -N -I $NASSERVER //$NASUSER@$NASIP/$NASSHARE $NASMNT
    	fi
    }
     
    umount_nas(){
    	$MOUNT | $GREP $NASMNT >/dev/null
    	[ $? -eq 0 ] && $UMOUNT $NASMNT 
    }
     
    backup_mysql(){
    	$LOGGER "$(basename $0) mysql: Started at $(date)"
    	local DBS="$($MYSQL -u $MUSER -h $MHOST -p$MPASS -Bse 'show databases')"
    	local db="";
    	[ ! -d $MBAKPATH/$NOW ] && $MKDIR -p $MBAKPATH/$NOW
    	for db in $DBS
    	do
    		local tTime=$(date +"${TIME_FORMAT}")
    		local FILE="${MBAKPATH}/$NOW/${db}.${tTime}.gz"
    		$MYSQLDUMP -u $MUSER -h $MHOST -p"$MPASS" $db | $GZIP -9 > $FILE
    		#mysql_file_hook $FILE
    	done
    	$LOGGER "$(basename $0) mysql: Ended at $(date)"
    }
     
    # process each sql database file and backup to another server via ssh
    # must have ssh keys
    mysql_file_hook(){
    	local f="$1"
    	local d=/nas/mysqlbackup/$(hostname -s)/$NOW
    	$SSH someuser@remote.nixcraft.com mkdir -p $d
    	$SCP $f someuser@remote.nixcraft.com:$d
    }
     
    case "$1" in
            mysql)
    		mount_nas
                    backup_mysql
    		umount_nas
                    ;;
            mount)
    		mount_nas;;
            umount)
    		umount_nas;;
            *)
                    echo "Usage: $0 {mysql|mount|umount}"
    esac
    
    exit 0
