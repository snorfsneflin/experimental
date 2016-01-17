


#!/bin/bash
#Backup MySQL Databases and compress them 
#Add this to cron
# @hourly /root/scripts/db1hr.backup.sh >/dev/null 2>&1# Dump all MySQL database every hour from raid10 db disk to /nas/mysql
# Each dump will be line as follows:
# Directory:  /nas/mysql/mm-dd-yyyy 
# File: mysql-DBNAME.04-25-2008-14:23:40.gz
# Full path: /nas/mysql/mm-dd-yyyy/mysql-DBNAME.04-25-2008-14:23:40.gz 
# -------------------------------------------------------------------------
# Copyright (c) 2005 nixCraft project <http://cyberciti.biz/fb/>
# This script is licensed under GNU GPL version 2.0 or above
# -------------------------------------------------------------------------
# This script is part of nixCraft shell script collection (NSSC)
# Visit http://bash.cyberciti.biz/ for more information.
# -------------------------------------------------------------------------
# Last updated: Jul-16-2009 - Fixed a small bug
#			    - Make sure NAS really mounted on $NAS
# -------------------------------------------------------------------------
NOW=$(date +"%m-%d-%Y") # mm-dd-yyyy format
FILE=""			# used in a loop
NASBASE="/nas"		# NAS Mount Point	
BAK="${NAS}/mysql/${NOW}" # Path to backup dir on $NAS
 
### Server Setup ###
#* MySQL login user name *#
MUSER="root"
 
#* MySQL login PASSWORD name *#
MPASS="YOUR-PASSWORD"
 
#* MySQL login HOST name *#
MHOST="127.0.0.1"
 
#* MySQL binaries *#
MYSQL="$(which mysql)"
MYSQLDUMP="$(which mysqldump)"
GZIP="$(which gzip)"
 
# Make sure nas is really mounted 
mount | awk '{ print $3}' |grep -w $NASBASE >/dev/null 
if [ $? -ne 0 ] 
then
	echo "Error: NAS not mounted at $NASBASE, please mount NAS server to local directory and try again."
	exit 99
fi
 
### NAS MUST BE MOUNTED in Advance ###
# assuming that /nas is mounted via /etc/fstab 
if [ ! -d $BAK ]; then
  mkdir -p $BAK
else
 :
fi
 
# get all database listing
DBS="$($MYSQL -u $MUSER -h $MHOST -p$MPASS -Bse 'show databases')"
 
# start to dump database one by one
for db in $DBS
do
 FILE=$BAK/mysql-$db.$NOW-$(date +"%T").gz
 # gzip compression for each backup file
 $MYSQLDUMP -u $MUSER -h $MHOST -p$MPASS $db | $GZIP -9 > $FILE
done

exit 0
