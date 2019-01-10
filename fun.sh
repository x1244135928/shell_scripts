#!/bin/bash

fun()

   {

   read -p "Enter a value:" value

   echo "double the value"

   return $[ $value * 2 ]
 
   }

fun
echo "the new value is $?"
