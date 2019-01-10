#!/bin/bash
#添加五十个账号 属于class1组

groupadd class1

for (( i=1;i<=50;i++ ))
 
    do

        useradd std$i -g class1

        echo "password" | passwd --stdin std$i

   done
