#!/bin/bash
if [ $# -le 3 ]
    
    then
    echo "三个参数如下：" 
    echo "arg1 : $1"

    echo "arg2 : $2  "  

    echo "arg3 : $3"

else
   
    echo "请输入三个参数"

    echo "usage:`basename $0` arg1 arg2 arg3"
fi

