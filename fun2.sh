#!/bin/bash

addem()
     { 

     if [ $# -eq 0 ] || [ $# -gt 2 ]

         then

             echo -1

     elif [ $# -eq 1 ]

         then

             echo $[ $1 + $1 ]

     else

             echo $[ $1 + $1 ]

     fi
}

echo -n "Adding 10 and 15:"

value=`addem 10 20`

echo $value

echo -n "just one number 10:"

value=`addem 10`

echo $value

echo -n "no numbers:"

value=`addem`

echo $value

echo -n "more than two numbers:"

value=`addem 10 15 20`

echo $value
