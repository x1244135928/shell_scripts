#!/bin/bash  
#测试一个脚本随机跑了多久

TIME_LIMIT=`expr $RANDOM % 10`

INITIME=1  

echo "Control-C to exit before $TIME_LIMIT seconds."  

while [ "$SECONDS" -le "$TIME_LIMIT" ]  

    do  
    
        if [ "$SECONDS" -eq 1 ]

            then  
            
                units=second  
    
        else    
        
                units=seconds  
  
        fi  
    
                echo "This script has been running $SECONDS $units."  
 
                sleep $INITIME  

    done  

                echo -e -n "\a"  # Beep!(哔哔声!)  
