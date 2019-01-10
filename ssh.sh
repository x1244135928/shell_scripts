#!/usr/bin/expect 

set timeout 5

spawn ssh 10.1.9.173

expect "*password:"

send "123456\r"

interact
