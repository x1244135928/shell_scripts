#!/bin/bash
# 删除50个用户 并且删除用户组 class1

for (( i=1;i<=50;i++ ))

    do

        userdel -r std$i

    done

        groupdel class1
