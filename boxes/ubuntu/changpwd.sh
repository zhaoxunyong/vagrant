#!/usr/bin/expect
set timeout -1
set PWD vagrant
spawn passwd 
expect "Enter new UNIX password:" 
send "$PWD\r"
expect "Retype new UNIX password:"
send "$PWD\r"
interact
#expect eof
