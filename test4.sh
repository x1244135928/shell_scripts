#!/bin/bash
function GetPID #User #Name 
 { 
    PsUser=$1 
    PsName=$2 
    pid=`ps -u $PsUser|grep $PsName|grep -v grep|grep -v vi|grep -v dbx\n 
    |grep -v tail|grep -v start|grep -v stop |sed -n 1p |awk '{print $1}'` 
    echo $pid 
 }
GetPID
