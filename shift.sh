#!/bin/bash


set -x
#遍历所有传入参数
until [ $# -eq 0 ]

    do

        echo "第一个参数为: $1 参数个数为: $#"

        shift #遍历所有传入参数
set +x
    done
