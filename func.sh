#!/bin/bash

File=/opt/fstab
{
read a1
read a2
read a3
read a4
read a5
read a6
read a7
read a8
} < $File

echo "First a in $File is: $a1"

echo "Second a in $File is: $a2"

echo "Thitf a in $File is: $a3"
echo "Thitf a in $File is: $a4"
echo "Thitf a in $File is: $a5"
echo "Thitf a in $File is: $a6"
echo "Thitf a in $File is: $a7"
echo "Thitf a in $File is: $a8"

exit 0
