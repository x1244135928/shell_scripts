#!/bin/bash
# 测试shift 的功能
if [ $# -eq 0 ]

    then

        echo "please usage:./x_shift2.sh 参数"

        exit 1

fi

sum=0

until [ $# -eq 0 ]
    
    do

        sum=`expr $sum + $1`

        shift

done

        echo "sum is: $sum"
