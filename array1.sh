#!/bin/bash
arr(){
	local newarr
        newarr=(` echo "$@" `) 
	len=${#newarr[@]}
	for((i=0; i<$len-1; i++)){
	  for((j=0; j<$len-1-i; j++)){
	    if [[ ${newarr[j]} -gt ${newarr[j+1]} ]];
	    then
	      temp=${newarr[j]}
	      newarr[j]=${newarr[j+1]}
	      newarr[j+1]=$temp
	    fi
	 
	  }
	}
	echo  ${newarr[*]}
}
read  -p "please input an array:"  -a arr
#arr=(1 5 29 7 2 20 34)
args=$(echo ${arr[*]})
arr1=(`arr  ${args}`)
echo "${arr1[*]}"
# 打印数组
#for item in  ${arr1[*]};
#do
#	echo $item |tr '\n'  ' '
#done
#echo ""
