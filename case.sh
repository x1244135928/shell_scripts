#!/bin/bash

read -t 30 -p "please input number{2,4,5,11,12,13,21,22,23,30}: " num

case $num in

     2)

         /sh/10.2.2.$num ;;

     4)
         
         /sh/10.2.2.$num ;;
    
     5)   
    
         /sh/10.2.2.$num ;;

     11)
  
         /sh/10.2.2.$num ;;

     12)

         /sh/10.2.2.$num ;;
    
     13)
    
         /sh/10.2.2.$num ;;
   
     21)
   
         /sh/10.2.2.$num ;;


     22)

         /sh/10.2.2.$num ;;

     23)

         /sh/10.2.2.$num ;;

     30)
          
         /sh/10.2.2.$num ;;

      *)

         echo  -e "\e[31m Please input right number\e[0m"  ;;

 
esac

