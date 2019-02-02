#!/bin/bash
# 7DTD Auto-Reveal Map
# Requirement: 
#  - Alloc's Fixes Mods installed to server
#  - Bad Company Mod installed to server
#  - Telnet enabled on the server
#
# This script is inteded to be run on a brand new 7DTD server that just has had its
# world generated and the administration is connecting to the server for the first time.
#
# Syntax: ./7dtd-run-after-initial-start.sh <absolute_path_to_7dtd_game_install_directory>
# 
# This script will:
#  - Loop until the first player joins the server.
#  - Set the permissions for the first player so that they are an admin
#  - Enable the rendering of the map, to be viewed by Alloc's Webinterface Map addon
#  - Calculate the appropriate start and end coordinates to pass to the expect script
#  - Call the expect script, let it auto-reveal the map
#  - Set a touch file so that if your server reboots, this script won't run again
#    * If you are starting a new world on an existing server, just delete the touch file /startloop.touch

# ONLY RUN THIS SCRIPT IF WE HAVENT RUN IT BEFORE
# [[ -f /startloop.touch ]] && exit

# ENSURE WE RECEIVED A VALID DIRECTORY PATH
if [[ ! -d "$1" ]]; then
  echo "ERROR: Please provide a valid path to your 7DTD game installation directory.";
  exit 1;
fi

# DELAY START TO GIVE 7DTD SERVER A CHANCE TO START
while true
do
  NETSTAT_CHECK=`netstat -anptu | grep LISTEN | grep 8081`
  [[ ! -z $NETSTAT_CHECK ]] && break;
  echo "Waiting for telnet server to start"; 
  sleep 3;
done
sleep 5; # Sleep an extra 5 seconds to make sure the telnet server truly has started

# ONLY SET VARIABLES IF THEY DONT ALREADY EXIST
[[ -z $7DTD_AUTOREVEAL_MAP ]] && export 7DTD_AUTOREVEAL_MAP=true
[[ ! -z $1 ]] && export INSTALL_DIR=$1
# The radiation border width is customizable so that you don't die while traversing the first or last row.
# Set this value too low, you will die.
export RADIATION_BORDER_WIDTH=350
export TELNETPORT=`grep 'name="TelnetPort"' $INSTALL_DIR/serverconfig.xml | awk '{print \$3}' | cut -d'"' -f2`;
export TELNETPASSWORD=`grep 'name="TelnetPassword"' $INSTALL_DIR/serverconfig.xml | awk '{print \$3}' | cut -d'"' -f2`;

# LOOP UNTIL FIRST PLAYER JOINS SERVER
while true
do
  # Look for an event of a player connecting to server
  PLAYERNAME=`grep 'Player connected' $INSTALL_DIR/7dtd.log | head -1 | awk '{print $7}' | cut -d, -f1 | cut -d= -f2`
  [[ ! -z $PLAYERNAME ]] && break;
  # Sleep for 5 seconds, then repeat
  echo "Looking for a Player to join the 7DTD Server.." && sleep 5
done

sleep 10
# ENABLE MAP RENDERING OF VISITED LOCATIONS
/7dtd-sendcmd.sh "rendermap"
sleep 2
/7dtd-sendcmd.sh "enablerendering"
sleep 2
# MAKE FIRST PLAYER AN ADMIN
/7dtd-sendcmd.sh "admin add $PLAYERNAME 0"
sleep 20

# CALCULATE START/STOP COORDINATES BASED ON MAP SIZE
MAPSIZE=`grep 'name="WorldGenSize"' $INSTALL_DIR/serverconfig.xml | awk '{print $3'} | cut -d'"' -f2`
#echo "MAPSIZE: $MAPSIZE / 2 - $RADIATION_BORDER_WIDTH=";
ENDING_COORD=`expr $MAPSIZE / 2 - $RADIATION_BORDER_WIDTH`;
#echo "ENDING_COORD: $ENDING_COORD"; 
STARTING_COORD=`expr $ENDING_COORD \* -1`
#echo "STARTING_COORD: $STARTING_COORD";

# RUN THE RENDER MAP loop script
[[ $7DTD_AUTOREVEAL_MAP ]] && /7dtd-auto-reveal-map/7dtd-autoreveal-map.sh $TELNETPORT \"$TELNETPASSWORD\" \"$PLAYERNAME\" $STARTING_COORD $ENDING_COORD

# CREATE TOUCH FILE SO WE DON'T RUN THIS MORE THAN ONCE
# touch /startloop.touch