#!/bin/bash

##############################################################################
# Script-Name : mysqldump_backup_full.sh                                     #
# Description : Script to backup the --all-databases of a MySQL/MariaDB.     #
#               On successful execution only a LOG file will be written.     #
#               On error while execution, a LOG file and a error message     #
#               will be send by e-mail.                                      #
#                                                                            #
# Last update : 07.02.2018                                                   #
# Version     : 1.00                                                         #
#                                                                            #
# Author      : Klaus Tachtler, <klaus@tachtler.net>                         #
# DokuWiki    : http://www.dokuwiki.tachtler.net                             #
# Homepage    : http://www.tachtler.net                                      #
#                                                                            #
#  +----------------------------------------------------------------------+  #
#  | This program is free software; you can redistribute it and/or modify |  #
#  | it under the terms of the GNU General Public License as published by |  #
#  | the Free Software Foundation; either version 2 of the License, or    |  #
#  | (at your option) any later version.                                  |  #
#  +----------------------------------------------------------------------+  #
#                                                                            #
# Copyright (c) 2018 by Klaus Tachtler.                                      #
#                                                                            #
##############################################################################

##############################################################################
#                                H I S T O R Y                               #
##############################################################################
# -------------------------------------------------------------------------- #
# Version     : x.xx                                                         #
# Description : <Description>                                                #
# -------------------------------------------------------------------------- #
# -------------------------------------------------------------------------- #
# Version     : x.xx                                                         #
# Description : <Description>                                                #
# -------------------------------------------------------------------------- #
##############################################################################

##############################################################################
# >>> Please edit following lines for personal settings and custom usages. ! #
##############################################################################
#eingefuegt von nkrings 18.01.2020
#PATH=/home/logoeu/bin:/usr/bin:/bin

# CUSTOM - Script-Name.
SCRIPT_NAME='mysqldump_backup_full'

# CUSTOM - Backup-Files.
DIR_BACKUP='/home/logoeu/tmp'
FILE_BACKUP=mysqldump_backup_`date '+%Y%m%d'`_prod.sql
FILE_DELETE='*.tar.gz'
BACKUPFILES_DELETE=4

# CUSTOM - mysqldump Parameter.
DUMP_HOST='localhost'
DUMP_USER='XXXXXXXX'
DUMP_PASS='XXXXXXXXXXXXXXXXXXX'
# CUSTOM - Binary-Logging active. Example: ('Y'(my.cnf|log_bin=bin-log), 'N')
DUMP_BIN_LOG_ACTIVE='N'
# CUSTOM - Depends on the database engine. Example: ('Y'(MyISAM), 'N'(InnoDB))
DUMP_LOCK_ALL_TABLE='N'

# CUSTOM - Mail-Recipient.
MAIL_RECIPIENT='nkr@logoeu.uber.space'

# CUSTOM - Status-Mail [Y|N].
MAIL_STATUS='Y'

##############################################################################
# >>> Normaly there is no need to change anything below this comment line. ! #
##############################################################################

# Variables.
MYSQLDUMP_COMMAND=`command -v mysqldump`
TAR_COMMAND=`command -v tar`
TOUCH_COMMAND=`command -v touch`
RM_COMMAND=`command -v rm`
PROG_SENDMAIL=`command -v sendmail`
CAT_COMMAND=`command -v cat`
DATE_COMMAND=`command -v date`
MKDIR_COMMAND=`command -v mkdir`
FILE_LOCK='/home/logoeu/tmp/'$SCRIPT_NAME'.lock'
FILE_LOG='/home/logoeu/logs/'$SCRIPT_NAME'.log'
FILE_LAST_LOG='/home/logoeu/tmp/'$SCRIPT_NAME'.log'
FILE_MAIL='/home/logoeu/tmp/'$SCRIPT_NAME'.mail'
FILE_MBOXLIST='/home/logoeu/tmp/'$SCRIPT_NAME'.mboxlist'
VAR_HOSTNAME=`uname -n`
VAR_SENDER='logopakt@'$VAR_HOSTNAME
VAR_EMAILDATE=`$DATE_COMMAND '+%a, %d %b %Y %H:%M:%S (%Z)'`

# Functions.
function log() {
        echo $1
        echo `$DATE_COMMAND '+%Y/%m/%d %H:%M:%S'` " INFO:" $1 >>${FILE_LAST_LOG}
}

function retval() {
if [ "$?" != "0" ]; then
        case "$?" in
        *)
                log "ERROR: Unknown error $?"
        ;;
        esac
fi
}

function movelog() {
        $CAT_COMMAND $FILE_LAST_LOG >> $FILE_LOG
        $RM_COMMAND -f $FILE_LAST_LOG
        $RM_COMMAND -f $FILE_LOCK
}

function sendmail() {
        case "$1" in
        'STATUS')
                MAIL_SUBJECT='Status execution '$SCRIPT_NAME' script.'
        ;;
        *)
                MAIL_SUBJECT='ERROR while execution '$SCRIPT_NAME' script !!!'
        ;;
        esac

$CAT_COMMAND <<MAIL >$FILE_MAIL
Subject: $MAIL_SUBJECT
Date: $VAR_EMAILDATE
From: $VAR_SENDER
To: $MAIL_RECIPIENT

MAIL

$CAT_COMMAND $FILE_LAST_LOG >> $FILE_MAIL

$PROG_SENDMAIL -f $VAR_SENDER -t $MAIL_RECIPIENT < $FILE_MAIL

$RM_COMMAND -f $FILE_MAIL

}

# Main.
log ""
log "+-----------------------------------------------------------------+"
log "| Start backup of --all-databases of database server............. |"
log "+-----------------------------------------------------------------+"
log ""
log "Run script with following parameter:"
log ""
log "SCRIPT_NAME...: $SCRIPT_NAME"
log ""
log "DIR_BACKUP....: $DIR_BACKUP"
log ""
log "MAIL_RECIPIENT: $MAIL_RECIPIENT"
log "MAIL_STATUS...: $MAIL_STATUS"
log ""

# Check if command (file) NOT exist OR IS empty.
if [ ! -s "$MYSQLDUMP_COMMAND" ]; then
        log "Check if command '$MYSQLDUMP_COMMAND' was found................[FAILED]"
        sendmail ERROR
        movelog
        exit 11
else
        log "Check if command '$MYSQLDUMP_COMMAND' was found................[  OK  ]"
fi

# Check if command (file) NOT exist OR IS empty.
if [ ! -s "$TAR_COMMAND" ]; then
        log "Check if command '$TAR_COMMAND' was found......................[FAILED]"
        sendmail ERROR
        movelog
        exit 12
else
        log "Check if command '$TAR_COMMAND' was found......................[  OK  ]"
fi

# Check if command (file) NOT exist OR IS empty.
if [ ! -s "$TOUCH_COMMAND" ]; then
        log "Check if command '$TOUCH_COMMAND' was found....................[FAILED]"
        sendmail ERROR
        movelog
        exit 13
else
        log "Check if command '$TOUCH_COMMAND' was found....................[  OK  ]"
fi

# Check if command (file) NOT exist OR IS empty.
if [ ! -s "$RM_COMMAND" ]; then
        log "Check if command '$RM_COMMAND' was found.......................[FAILED]"
        sendmail ERROR
        movelog
        exit 14
else
        log "Check if command '$RM_COMMAND' was found.......................[  OK  ]"
fi

# Check if command (file) NOT exist OR IS empty.
if [ ! -s "$CAT_COMMAND" ]; then
        log "Check if command '$CAT_COMMAND' was found......................[FAILED]"
        sendmail ERROR
        movelog
        exit 15
else
        log "Check if command '$CAT_COMMAND' was found......................[  OK  ]"
fi

# Check if command (file) NOT exist OR IS empty.
if [ ! -s "$DATE_COMMAND" ]; then
        log "Check if command '$DATE_COMMAND' was found.....................[FAILED]"
        sendmail ERROR
        movelog
        exit 16
else
        log "Check if command '$DATE_COMMAND' was found.....................[  OK  ]"
fi

# Check if command (file) NOT exist OR IS empty.
if [ ! -s "$MKDIR_COMMAND" ]; then
        log "Check if command '$MKDIR_COMMAND' was found....................[FAILED]"
        sendmail ERROR
        movelog
        exit 17
else
        log "Check if command '$MKDIR_COMMAND' was found....................[  OK  ]"
fi

# Check if command (file) NOT exist OR IS empty.
if [ ! -s "$PROG_SENDMAIL" ]; then
        log "Check if command '$PROG_SENDMAIL' was found................[FAILED]"
        sendmail ERROR
        movelog
        exit 18
else
        log "Check if command '$PROG_SENDMAIL' was found................[  OK  ]"
fi

# Check if LOCK file NOT exist.
if [ ! -e "$FILE_LOCK" ]; then
        log "Check if script is NOT already runnig .....................[  OK  ]"

        $TOUCH_COMMAND $FILE_LOCK
else
        log "Check if script is NOT already runnig .....................[FAILED]"
        log ""
        log "ERROR: The script was already running, or LOCK file already exists!"
        log ""
        sendmail ERROR
        movelog
        exit 20
fi

# Check if DIR_BACKUP Directory NOT exists.
if [ ! -d "$DIR_BACKUP" ]; then
        log "Check if DIR_BACKUP exists.................................[FAILED]"
        $MKDIR_COMMAND -p $DIR_BACKUP
        log "DIR_BACKUP was now created.................................[  OK  ]"
else
        log "Check if DIR_BACKUP exists.................................[  OK  ]"
fi

# Start backup.
log ""
log "+-----------------------------------------------------------------+"
log "| Run backup $SCRIPT_NAME .............................. |"
log "+-----------------------------------------------------------------+"
log ""

# Start backup process via mysqldump.

cd $DIR_BACKUP

if [ $DUMP_LOCK_ALL_TABLE = 'Y' ]; then
        DUMP_LOCK_ALL_TABLE='--lock-all-tables'
else
        DUMP_LOCK_ALL_TABLE='--single-transaction'
fi

if [ $DUMP_BIN_LOG_ACTIVE = 'Y' ]; then
        log "Dump data with bin-log data ..."
        $MYSQLDUMP_COMMAND --host=$DUMP_HOST --user=$DUMP_USER --password=$DUMP_PASS --all-databases --flush-privileges $DUMP_LOCK_ALL_TABLE --master-data=1 --flush-logs --triggers --routines --events --hex-blob > $FILE_BACKUP
else
        log "Dump data ..."
        $MYSQLDUMP_COMMAND --host=$DUMP_HOST --user=$DUMP_USER --password=$DUMP_PASS --all-databases --flush-privileges $DUMP_LOCK_ALL_TABLE --triggers --routines --events --hex-blob > $FILE_BACKUP
fi

log ""
log "Packaging to archive ..."
$TAR_COMMAND -cvzf $FILE_BACKUP.tar.gz $FILE_BACKUP --atime-preserve --preserve-permissions

log ""
log "Delete archive files ..."
(ls $FILE_DELETE -t|head -n $BACKUPFILES_DELETE;ls $FILE_DELETE )|sort|uniq -u|xargs rm
if [ "$?" != "0" ]; then
        log "Delete old archive files $DIR_BACKUP .....[FAILED]"
else
        log "Delete old archive files $DIR_BACKUP ........[  OK  ]"
fi

log ""
log "Delete dumpfile ..."
$RM_COMMAND $FILE_BACKUP

# Delete LOCK file.
if [ "$?" != "0" ]; then
        retval $?
        log ""
        $RM_COMMAND -f $FILE_LOCK
        sendmail ERROR
        movelog
        exit 99
else
        log ""
        log "+-----------------------------------------------------------------+"
        log "| End backup $SCRIPT_NAME .............................. |"
        log "+-----------------------------------------------------------------+"
        log ""
fi

# Finish syncing.
log "+-----------------------------------------------------------------+"
log "| Finish......................................................... |"
log "+-----------------------------------------------------------------+"
log ""

# Status e-mail.
if [ $MAIL_STATUS = 'Y' ]; then
        sendmail STATUS
fi
# Move temporary log to permanent log
movelog

exit 0
