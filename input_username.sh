#!/bin/bash
#用户交互输入用户名和密码
i=0
while [ $i -le 3 ]

   do 

       echo -n "login:"

       read name

       echo -n "password:"

       read passwd
       
       let  i+=1

       set -x

       if [ $name = "xl" -a $passwd = "xl123456789" ] # -a表示与，表示两个条件均成立
   
           then

               echo -e "\e[32m INPUT IS RIGHT!!!\e[0m"
 
               echo -e "\e[32m 您第 "$i" 次输入正确\e[0m"
         
               break

       else 

               echo -e "\e[31m INPUT IS ERROR!!!\e[0m"
      
       fi
      

   done
