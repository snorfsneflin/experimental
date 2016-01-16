    #!/bin/bash
    # mybackupadd - Add file to ~/.mybackup file, then backup and email all
    # file as tar.gz to your email a/c.
    #
    # Usage   : ./mybackupadd ~/public_html/
    #
    # Copyright (C) 2004 nixCraft project
    # Email   : http://cyberciti.biz/fb/
    # Date    : Aug-2004
    # -------------------------------------------------------------------------
    # This program is free software; you can redistribute it and/or
    # modify it under the terms of the GNU General Public License
    # as published by the Free Software Foundation; either version 2
    # of the License, or (at your option) any later version.
    # -------------------------------------------------------------------------
    # This script is part of nixCraft shell script collection (NSSC)
    # Visit http://bash.cyberciti.biz/ for more information.
    # -------------------------------------------------------------------------
     
    FILE=~/.mybackup
    MYH=~
    CWD=`pwd`
    SRC=$1
     
    if [ "$SRC" == "" ]; then
      echo "Must supply dir or file name"
      exit 1
    fi  
    # if list $FILE does not exist
    [ ! -f $FILE ] && touch $FILE || :
     
    # make sure that file or dir exists to backup
    if [ ! -f $SRC ]; then
       if [ ! -d $SRC ]; then
          echo "$SRC does not exists"
          exit 2
       fi
    fi
    # make sure we don't do add duplicate stuff
    cat $FILE | grep -w $SRC > /dev/null
    if [ "$?" == "0" ]; then
       echo "$SRC exists in $FILE"
       exit 3
    fi 
    # okay now add that to backup list
    echo "$SRC" >> $FILE
    echo "$SRC added to $FILE"
