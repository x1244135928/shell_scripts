#!/bin/bash

set -x
export ARGS=2
E_BADARGS=65
  
if [ $# -ne "$ARGS" ]
    
    then
    
    echo "Usage: `basename $0` only need two args"
    
    exit $E_BADARGS
 
fi
   
gcd ()
 
   {
  
      dividend=$1                  #  随意赋值.
   
      divisor=$2                   #  在这里, 哪个值给的大都没关系.
 
      remainder=1                  #  在循环中使用了初始化的变量, 
 
      until [ "$remainder" -eq 0 ]
    
         do
        
         let "remainder = $dividend % $divisor"
        
         dividend=$divisor         # 现在使用两个最小的数来重复.
      
         divisor=$remainder
    
         done                      
  
   }                               # Last $dividend is the gcd.
  
 
gcd $1 $2
  
    echo; echo "GCD of $1 and $2 is:  $dividend"; echo
    
                                   #  检查传递进来的命令行参数来确保它们都是整数.
                                   #+ 如果不是整数, 那就给出一个适当的错误消息并退出脚本.
  
    exit 0
set +x
