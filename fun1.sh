#!/bin/bash

myfun()
     
     {

     read -p "Enter a value:" value

     echo $[ $value * 2 ]

     }

     result=`myfun`

     echo "the new valude is $result"
