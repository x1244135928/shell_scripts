#!/bin/bash
read -p "please input a array:" -a attr

echo_input(){
for i in $*

do
echo $i
done
}
echo_input ${attr[@]}
