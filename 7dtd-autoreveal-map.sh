#!/usr/bin/expect
# 7DTD Auto-Reveal Map
#
# This script is intended to be called from 7dtd-run-after-initial-start.sh
# Syntax: ./7dtd-rendermap.sh <TelnetPort> <TelnetPassword> <PlayerName> <StartingCoordinate> <EndingCoordinate>
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
#  - Break the entire map up into 140 sized blocks. 
#  - Loop over all the block coordinates
#      - teleport the player to a height of 200
#      - Waits 2 seconds 
#      - teleports the player to a height of 0
#      - Waits 2 seconds
#      - Teleports player to next block coordinates 
#  - Take hours to complete.

set TELNETPORT [lindex $argv 0];
set TELNETPASSWORD [lindex $argv 1];
set PLAYER [lindex $argv 2];
set START_COORD [lindex $argv 3];
set END_COORD [lindex $argv 4];

set timeout 5; set first_height 200; set second_height 0; set viewed_block_size 140; set sleep_one 1; set sleep_two 2; set count 0;
spawn telnet 127.0.0.1 $TELNETPORT; 
expect "Please enter password:"; 
send "$TELNETPASSWORD\r";
send_user "Teleporting player across the map";
for {set y $START_COORD} {$y < $END_COORD} {incr y $viewed_block_size} {
  for {set x $START_COORD} {$x < $END_COORD} {incr x $viewed_block_size} {
    incr count; send "bc-teleport entity $PLAYER $x $first_height $y\r"; sleep $sleep_one; 
    send "bc-teleport entity $PLAYER $x $second_height $y\r"; sleep $sleep_two;
  }
}
send "bc-teleport entity $PLAYER 0 0 0\r"; send "exit\r"; expect eof