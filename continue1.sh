#!/bin/bash
n=3
for(( i=1; i<=10; i++ ))
   do 
      let a=i%3
      if [ $a -eq 0 ]
         then
         break
      fi
         echo $i
   done  
