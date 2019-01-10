#!/bin/bash
file="/etc/passwd"

line=`cat /etc/passwd |wc -l`

for I in `seq 1 $line`

do

username=`head -$I $file|tail -1 |cut -d: -f1` 

userid=`head -$I $file|tail -1 |cut -d: -f3` 

echo "hello $username,your ID is $userid "


done 

read -p "input you id or name" userorname

