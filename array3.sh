#!/bin/bash
if read -t 10 -p "请输入一个数组:" -a a
then
echo "你输入的数组为：" ${a[*]}
echo "你输入的数组为：" ${a[@]}
else
echo "输入超时"
fi
exit 0


