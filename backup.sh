#!/bin/bash

BACKUP_DATA=`date +%Y%m%d` #取时间戳

IPADDR=`cat  /opt/switch_list11  | awk '{print $1 }'` #账号密码及IP地址存放在user.passwd中，通过awk获取所有IP并存放在数组

for ipaddr in  ${IPADDR[@]}  #for循环，取出所有ip地址复制ipaddr 
 
    do 
                                        
        echo  -e "`date +%H:%M:%S`  开始备份: \e[31m $ipaddr\e[0m" #输出备份开始时间

        PASSWORD=(`cat /opt/switch_list11 | awk '{print $2}'`) #取出相应交换机的密码

        /usr/bin/expect   <<  EOF 

        set timeout 10

        spawn telnet $ipaddr

        expect "Username:"               

        send "admin\r"  

        expect "*Password: "
 
        send "$PASSWORD\r"

        expect "*>"

        send "ftp 10.1.2.10\r"
        
        expect "*(none)):"
        
        send "ftpuser\r"
 
        expect "Enter password:"
 
        send "l@2018\r"

        expect "*ftp]"

        send "put flash:/vrpcfg.zip /backup11f/${ipaddr}_${BACKUP_DATA}.zip\r"

        send "quit\r"
EOF

        echo "`date +%H:%M:%S`  备份完成: $ipaddr"

    done
