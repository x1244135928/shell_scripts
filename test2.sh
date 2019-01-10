#!/bin/bash

read -p "输入参数："  $@

for each in $@

 do

echo "each 里面的每个数 $each"

done

echo " "\$#" 的值 $#"
echo " "\$*"的值 $*"
