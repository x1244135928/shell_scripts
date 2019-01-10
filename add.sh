#!/bin/bash
sum=0
#计算用户输入的数字之和
for(( i=1; i<=$1; i++ ))
    do
     let sum=$sum+$i
    done
         echo $sum
