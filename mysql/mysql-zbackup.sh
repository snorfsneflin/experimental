#!/bin/bash

#Create backup file name
#############
FILENAME="mysql-backup-$(date +%F).tar.gz"

#MySQL Credentials
#############
MUSER="root"
MPASS="youpassword"

#Paths 
TPATH="/tmp/mysqlbackup"
BPATH="/root"

#Dependencies
############
MYSQL="$(which mysql)"
MYSQLDUMP="$(which mysqldump)"
TAR="$(which tar)"
DBS="$(mysql -u root -p$MPASS -Bse 'show databases')"

#Create tmp dir
#TODO: use a real tmp directory
############
if [ ! -d "$TPATH" ];
  then
    mkdir -p "$TPATH"
    echo "Created Directory $TPATH"
  else
    echo "Using Directory $TPATH"
fi

#Backup
############

for db in $DBS
do
$MYSQLDUMP -u $MUSER -p$MPASS $db > $TPATH/$db.sql
done

#Compress and remove tmp dir
############
echo "Compressing Databases"
"$TAR zcf" "$BPATH"/"$FILENAME" "$TPATH"

#echo "Removing Temp Directory"
#/bin/rm -rf $TPATH
