#!/bin/bash
# 此为备份mysql 数据库
backupdir=/data/mysql_backup

/usr/bin/mysqldump -uroot -p'123456' mysql | gzip > $backupdir/mysql_$time.sql.gz

find $backupdir -name "mysql_*.sql.gz" -type f -mtime +5 -exec rm -rf {} \; > /dev/null 2>&1 

