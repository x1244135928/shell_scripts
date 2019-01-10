#!/bin/bash
n=1
while [ $n -eq 1 ]
   do
       read -p "Enter your name:" name
       read -p "Enter you enmpoyee number:" num
      
       case  $name in
           "stop")
               if [ "$num" -le  100 ]
                   then
                   continue
               else
                   break
               fi
               ;;
           *) 
        echo "Hello,$name you number is $num"
               ;;
        esac     
          
    done
        echo "good bye"
