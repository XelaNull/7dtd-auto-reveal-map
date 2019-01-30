#!/usr/bin/expect
# This script is intended to be called from 7dtd-startloop.sh
# Syntax: ./7dtd-rendermap.sh <PlayerName> <StartingCoordinate> <EndingCoordinate>
set TELNETPORT 8081;
set TELNETPASSWORD sanity;
set timeout 5; set first_height 200; set second_height 0; set viewed_block_size 140; set sleep 2; set count 0; 
spawn telnet 127.0.0.1 $TELNETPORT; expect "Please enter password:"; send "$TELNETPASSWORD\r";
for {set y $2} {$y < $3} {incr y $viewed_block_size} {
  for {set x $2} {$x < $3} {incr x $viewed_block_size} { 
    incr count; send "bc-teleport entity $1 $x $first_height $y\r"; sleep $sleep; send "bc-teleport entity $1 $x $second_height $y\r"; sleep $sleep
  }
}
send "bc-teleport entity $1 0 0 0\r"; send "exit\r"; expect eof