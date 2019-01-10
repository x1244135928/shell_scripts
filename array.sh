#!/bin/bash
arr(){
    old=($(echo "$@"))
    new=($(echo "$@"))
    count=$[ $# - 1 ]
    for (( i = 0; i <= $count; i++ ))
    {
    new[$i]=$[ ${old[$i]} * 2 ]
    }
    echo ${new[*]}
}  
myarr=(1 2 3 4 5)
echo "The old array is: ${myarr[*]}"
arg1=$(echo ${myarr[*]})
result=($(arr $arg1))
echo "The new array is: ${result[*]}"
