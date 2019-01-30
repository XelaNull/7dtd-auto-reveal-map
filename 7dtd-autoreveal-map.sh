#!/usr/bin/expect
# 7DTD Auto-Reveal Map
#
# This script is intended to be called from 7dtd-startloop.sh
# Syntax: ./7dtd-rendermap.sh <PlayerName> <StartingCoordinate> <EndingCoordinate>
#
# Requirement: 
#  - Alloc's Fixes Mods installed to server
#  - Bad Company Mod installed to server
#  - Telnet enabled on the server
#
# This script is inteded to be run on a brand new 7DTD server that just has had its
# world generated and the administration is connecting to the server for the first time.
# 
# This script will:
#  - Loop through all locations on a map, to allow the player to "see" everywhere in the map
#  - Take hours to complete.

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