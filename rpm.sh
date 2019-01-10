#!/bin/bash
#显示一个rpm 包的详细信息

for rpmpackage in $*

   do

      if [ -f $rpmpackage ]

          then

          echo -e "\e[34m===============$rpmpackage==============\e[0m"

          rpm -qi -p $rpmpackage

      else

          echo "Error cannot read file $rpmpackage"

      fi

          echo -e "\e[31m $*\e[0m" 

          echo -e "\e[32m $#\e[0m" 

          echo -e "\e[33m $@\e[0m" 

   done
