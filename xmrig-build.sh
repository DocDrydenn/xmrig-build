#!/bin/bash

VERS="v1.9"

# Clear screen
clear

# Error Trapping with Cleanup
errexit() {
  # Draw 5 lines of + and message
  for i in {1..5}; do echo "+"; done
  echo -e "\e[91mError raised! Cleaning Up and Exiting.\e[39m"
  
  # Remove _source directory if found.
  if [ -d "$SCRIPTPATH/_source" ]; then rm -r $SCRIPTPATH/_source; fi
  
  # Remove xmrig directory if found.
  if [ -d "$SCRIPTPATH/xmrig" ]; then rm -r $SCRIPTPATH/xmrig; fi
  
  # Dirty Exit
  exit 1
}

# Phase Header
phaseheader() {
  echo
  echo -e "\e[32m=======================================\e[39m"
  echo -e "\e[35m- $1..."
  echo -e "\e[32m=======================================\e[39m"
}

# Phase Footer
phasefooter() {
  echo -e "\e[32m=======================================\e[39m"
  echo -e "\e[35m $1 Completed"
  echo -e "\e[32m=======================================\e[39m"
  echo
}

# Intro/Outro Header
inoutheader() {
  echo -e "\e[32m=================================================="
  echo -e "==================================================\e[39m"
  echo " XMRig Build Script $VERS"

  [ $BUILD -eq 7 ] && echo " for ARMv7"
  [ $BUILD -eq 8 ] && echo " for ARMv8"
  [ $BUILD -eq 0 ] && echo " for x86-64"

  echo " by DocDrydenn @ getpimp.org"
  echo

  if [[ "$DEBUG" = "1" ]]; then echo -e "\e[5m\e[96m++ DEBUG ENABLED - SKIPPING BUILD PROCESS ++\e[39m\e[0m"; echo; fi
}

# Intro/Outro Footer
inoutfooter() {
  echo -e "\e[32m=================================================="
  echo -e "==================================================\e[39m"
  echo
}

# Error Trap
trap 'errexit' ERR

# Setup Variables
SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
BUILD=0
DEBUG=0

# Parse Commandline Arguments
[ "$1" = "7" ] && BUILD=7
[ "$1" = "8" ] && BUILD=8
[ "$1" = "d" ] && DEBUG=1
[ "$2" = "d" ] && DEBUG=1

# Opening Intro
inoutheader
inoutfooter

# Check for curl
if [[ $(which curl 1&>1; echo $?) != "1" ]] # Production
#if [[ $(which curl 1&>1; echo $?) = "1" ]] # Testing
then
  echo "Warning: CURL not found."
  echo
  echo "This script uses CURL to check for updates."
  echo
  read -r -p "Do you want to continue without checking? (not recommended) [y/N] " response
  curlresponse=${response,,}
  if [[ $curlresponse =~ ^(no|n| ) ]] || [[ -z $curlresponse ]]
  then
    echo
    echo "Note: This script can attempt to install CURL and try again."
    echo
    read -r -p "Would you like to install CURL and try again? (recommended) [Y/n] " response
    installresponse=${response,,}
    if [[ $installresponse =~ ^(yes|y| ) ]] || [[ -z $installresponse ]]
    then
      echo
      echo "Attempting to install CURL..."
      echo
      apt install curl -y
      echo
      echo "Restarting script..."
      echo
      exec $0
    else
      echo
      echo "Script Aborted."
      exit 0
    fi
  else
    echo
    echo "Continuing..."
    sleep 3
  fi
else
  # New Version Notification/Prompt
  LVER="$(curl -sI "https://github.com/DocDrydenn/xmrig-build/releases/latest" | grep -Po 'tag\/\K(v\S+)')"
  if [[ "$VERS" != "$LVER" ]]
  then
    echo -e "\e[5m\e[44m++ New Version Detected ++\e[39m\e[0m"
    echo
    echo " $VERS - Current"
    echo " $LVER - Online"
    echo
    read -r -p "Do you want to continue anyway? (not recommended) [y/N] " response
    response=${response,,}
    if [[ $response =~ ^(no|n| ) ]] || [[ -z $response ]]
    then
      echo
      echo "Script Aborted."
      exit 0
    else
      echo
      echo "Continuing..."
      sleep 3
    fi
  fi
fi

### Start Phase 6
PHASE="Dependancies"
phaseheader $PHASE 

# Install required tools for building from source
[ $DEBUG -eq 1 ] && echo -e "\e[96m++ $PHASE - apt update && apt upgrade -y\e[39m"
apt update && apt upgrade -y
[ $DEBUG -eq 1 ] && echo -e "\e[96m++ $PHASE - apt install git build-essential cmake libuv1-dev libssl-dev libhwloc-dev screen p7zip-full curl -y\e[39m"
apt install git build-essential cmake libuv1-dev libssl-dev libhwloc-dev screen p7zip-full -y

### End Phase 6
phasefooter $PHASE

### Start Phase 5
PHASE="Backup"
phaseheader $PHASE 
if [ -d "$SCRIPTPATH/xmrig" ]
then
  if [ -f "$SCRIPTPATH/xmrig/xmrig-build.7z.bak" ]
  then
    # Remove last backup archive
    [ $DEBUG -eq 1 ] && echo -e "\e[96m++ $PHASE - rm $SCRIPTPATH/xmrig/xmrig-build.7z.bak\e[39m"
    rm $SCRIPTPATH/xmrig/xmrig-build.7z.bak
    echo "xmrig-build.7z.bak removed"
  else
    echo "xmrig-build.7z.bak doesn't exist - Skipping Delete..."
  fi
  if [ -f "$SCRIPTPATH/xmrig/xmrig.bak" ]
  then
    # Remove last backup binary
    [ $DEBUG -eq 1 ] && echo -e "\e[96m++ $PHASE - rm $SCRIPTPATH/xmrig/xmrig.bak\e[39m"
    rm $SCRIPTPATH/xmrig/xmrig.bak
    echo "xmrig.bak removed"
  else
    echo "xmrig.bak doesn't exist - Skipping Delete..."
  fi
  if [ -f "$SCRIPTPATH/xmrig/xmrig-build.7z" ]
  then
    # Backup last archive
    [ $DEBUG -eq 1 ] && echo -e "\e[96m++ $PHASE - mv $SCRIPTPATH/xmrig/xmrig-build.7z $SCRIPTPATH/xmrig/xmrig-build.7z.bak\e[39m"
    mv $SCRIPTPATH/xmrig/xmrig-build.7z $SCRIPTPATH/xmrig/xmrig-build.7z.bak
    echo "xmrig-build.7z renamed to xmrig-build.7z.bak"
  else
    echo "xmrig-build.7z doesn't exist - Skipping Backup..."
  fi
  if [ -f "$SCRIPTPATH/xmrig/xmrig" ]
  then
    # Backup last binary
    [ $DEBUG -eq 1 ] && echo -e "\e[96m++ $PHASE - mv $SCRIPTPATH/xmrig/xmrig $SCRIPTPATH/xmrig/xmrig.bak\e[39m"
    mv $SCRIPTPATH/xmrig/xmrig $SCRIPTPATH/xmrig/xmrig.bak
    echo "xmrig renamed to xmrig.bak"
  else
    echo "xmrig doesn't exist - Skipping Backup..."
  fi
else
  # Make xmrig folder if it doesn't exist
  echo "Creating xmrig directory..."
  [ $DEBUG -eq 1 ] && echo -e "\e[96m++ $PHASE - mkdir -p $SCRIPTPATH/xmrig\e[39m"
  mkdir -p $SCRIPTPATH/xmrig
fi

### End Phase 5
phasefooter $PHASE

### Start Phase 4
PHASE="Setup"
phaseheader $PHASE

# If a _source directory is found, remove it.
if [ -d "$SCRIPTPATH/_source" ]
then
  [ $DEBUG -eq 1 ] && echo -e "\e[96m++ $PHASE - rm -r $SCRIPTPATH/_source\e[39m"
  rm -r $SCRIPTPATH/_source
fi

# Make new source folder
[ $DEBUG -eq 1 ] && echo -e "\e[96m++ $PHASE - mkdir $SCRIPTPATH/_source\e[39m"
mkdir $SCRIPTPATH/_source

# Change working dir to source folder
[ $DEBUG -eq 1 ] && echo -e "\e[96m++ $PHASE - cd $SCRIPTPATH/_source\e[39m"
cd $SCRIPTPATH/_source

# Clone XMRig from github into source folder
[ $DEBUG -eq 1 ] && echo -e "\e[96m++ $PHASE - git clone https://github.com/xmrig/xmrig.git\e[39m"
git clone https://github.com/xmrig/xmrig.git

# Change working dir to clone - Create build folder - Change working dir to build folder
[ $DEBUG -eq 1 ] && echo -e "\e[96m++ $PHASE - cd xmrig && mkdir build && cd build\e[39m"
cd xmrig && mkdir build && cd build

### End Phase 4
phasefooter $PHASE

### Start Phase 3
PHASE="Compiling/Building"
phaseheader $PHASE

# Setup build enviroment
[ $DEBUG -eq 1 ] && [ $BUILD -eq 7 ] && echo -e "\e[96m++ $PHASE - cmake .. -DCMAKE_BUILD_TYPE=Release -DARM_TARGET=7 -DWITH_OPENCL=OFF -DWITH_CUDA=OFF -DWITH_HWLOC=OFF -DWITH_ASM=OFF\e[39m"
[ $BUILD -eq 7 ] && cmake .. -DCMAKE_BUILD_TYPE=Release -DARM_TARGET=7 -DWITH_OPENCL=OFF -DWITH_CUDA=OFF -DWITH_HWLOC=OFF -DWITH_ASM=OFF
[ $DEBUG -eq 1 ] && [ $BUILD -eq 8 ] && echo -e "\e[96m++ $PHASE - cmake .. -DCMAKE_BUILD_TYPE=Release -DARM_TARGET=7 -DWITH_OPENCL=OFF -DWITH_CUDA=OFF -DWITH_HWLOC=OFF -DWITH_ASM=OFF\e[39m"
[ $BUILD -eq 8 ] && cmake .. -DCMAKE_BUILD_TYPE=Release -DARM_TARGET=8 -DWITH_OPENCL=OFF -DWITH_CUDA=OFF -DWITH_HWLOC=OFF -DWITH_ASM=OFF
[ $DEBUG -eq 1 ] && [ $BUILD -eq 0 ] && echo -e "\e[96m++ $PHASE - cmake .. -DCMAKE_BUILD_TYPE=Release\e[39m"
[ $BUILD -eq 0 ] && cmake .. -DCMAKE_BUILD_TYPE=Release

# Bypass make process if debug is enabled.
if [[ "$DEBUG" = "1" ]]
then
  echo -e "\e[96m++ $PHASE - touch xmrig\e[39m"
  touch xmrig
else
  make
fi

# End Phase 3
phasefooter $PHASE

### Start Phase 2
PHASE="Compressing/Moving"
phaseheader $PHASE

# Compress built xmrig into archive
[ $DEBUG -eq 1 ] && echo -e "\e[96m++ $PHASE - 7z a xmrig-build.7z $SCRIPTPATH/xmrig\e[39m"
7z a xmrig-build.7z $SCRIPTPATH/xmrig

# Copy archive to xmrig folder
[ $DEBUG -eq 1 ] && echo -e "\e[96m++ $PHASE - cp xmrig-build.7z $SCRIPTPATH/xmrig/xmrig-build.7z\e[39m"
cp xmrig-build.7z $SCRIPTPATH/xmrig/xmrig-build.7z

# Copy built xmrig to xmrig folder
[ $DEBUG -eq 1 ] && echo -e "\e[96m++ $PHASE - cp $SCRIPTPATH/_source/xmrig/build/xmrig $SCRIPTPATH/xmrig/xmrig\e[39m"
cp $SCRIPTPATH/_source/xmrig/build/xmrig $SCRIPTPATH/xmrig/xmrig

# End Phase 2
phasefooter $PHASE

# Start Phase 1
PHASE="Cleanup"
phaseheader $PHASE

# Change working dir back to root
[ $DEBUG -eq 1 ] && echo -e "\e[96m++ $PHASE - cd $SCRIPTPATH\e[39m"
cd $SCRIPTPATH

# Remove source folder
[ $DEBUG -eq 1 ] && echo -e "\e[96m++ $PHASE - rm -r _source\e[39m"
rm -r _source
echo "Source directory removed."

# Create start-example.sh
if [ ! -f "$SCRIPTPATH/xmrig/start-example.sh" ]
then
  [ $DEBUG -eq 1 ] && echo -e "\e[96m++ $PHASE - cat > $SCRIPTPATH/xmrig/start-example.sh <<EOF\e[39m"
cat > $SCRIPTPATH/xmrig/start-example.sh <<EOF
#! /bin/bash

screen -wipe
screen -dm $SCRIPTPATH/xmrig/xmrig -o <pool_IP>:<pool_port> -l /var/log/xmrig-cpu.log --donate-level 1 --rig-id <rig_name> -k --verbose
screen -r
EOF
  echo "start-example.sh created."

  # Make start-example.sh executable
  [ $DEBUG -eq 1 ] && echo -e "\e[96m++ $PHASE - chmod +x $SCRIPTPATH/xmrig/start-example.sh\e[39m"
  chmod +x $SCRIPTPATH/xmrig/start-example.sh
  echo "start-example.sh made executable."
fi

# End Phase 1
phasefooter $PHASE

# Close Out
inoutheader
echo " Folder Location: $SCRIPTPATH/xmrig/"
echo " Bin: $SCRIPTPATH/xmrig/xmrig"
echo " Example Start Script: $SCRIPTPATH/xmrig/start-example.sh"
echo
inoutfooter

# Clean exit of script
exit 0