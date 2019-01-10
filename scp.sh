#!/bin/bash


IPADDR=""
DIR="/share"
OS_Version=`(awk '{print $(NF-1)}' /etc/redhat-release)`
   
    if [[ $OS_Version < 7 ]]
        then

        IPADDR=`ifconfig | grep 'Bcast'|awk -F "[: ]+" '{print $4}'`
        
        echo "本机IP地址：$IPADDR"
    else

        IPADDR=`ifconfig | grep inet | head -1 |awk -F "[: ]+" '{print $3}'`

        echo "本机IP地址：$IPADDR"
    fi

        [ -d $DIR ]||mkdir -p $DIR
   
        echo -e "OS_Version:\e[31m$OS_Version\e[0m"
        
/usr/bin/expect << EOF
 
    set timeout 5

    spawn ssh 10.1.28.40
    
    expect "password:"
 
    send "123.com\r"
  
    interact
EOF
    

