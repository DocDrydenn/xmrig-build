#!/bin/bash

VERS="v2.0d"


# Required Packages
PackagesArray=('build-essential' 'cmake' 'libuv1-dev' 'libssl-dev' 'libhwloc-dev' 'screen' 'p7zip-full')

# Setup Variables
#SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
BUILD=0
DEBUG=0
STATIC=0
SCRIPT="$(readlink -f "$0")"
SCRIPTFILE="$(basename "$SCRIPT")"
SCRIPTPATH="$(dirname "$SCRIPT")"
SCRIPTNAME="$0"
ARGS=( "$@" )
BRANCH="develop"


# Usage Example Function
usage_example() {
  echo " Usage:  xmrig-build [-dhs] -<0|7|8>"
  echo
  echo "    -0 | 0 | <blank>      - x86-64"
  echo "    -7 | 7                - ARMv7"
  echo "    -8 | 8                - ARMv8"
  echo
  echo "    -s | s                - Build Static"
  echo
  echo "    -h | h                - Display (this) Usage Output"
  echo "    -d | d                - Enable Debug Output"
  echo
  exit 0
}

# Flag Processing Function
flags() {
  ([ "$1" = "-h" ] || [ "$1" = "h" ]) && usage_example
  ([ "$2" = "-h" ] || [ "$2" = "h" ]) && usage_example
  ([ "$3" = "-h" ] || [ "$3" = "h" ]) && usage_example
  ([ "$4" = "-h" ] || [ "$4" = "h" ]) && usage_example

  ([ "$1" = "d" ] || [ "$1" = "-d" ]) && DEBUG=1
  ([ "$2" = "d" ] || [ "$2" = "-d" ]) && DEBUG=1
  ([ "$3" = "d" ] || [ "$3" = "-d" ]) && DEBUG=1

  ([ "$1" = "-s" ] || [ "$1" = "s" ]) && STATIC=1
  ([ "$2" = "-s" ] || [ "$2" = "s" ]) && STATIC=1
  ([ "$3" = "-s" ] || [ "$3" = "s" ]) && STATIC=1

  ([ "$1" = "7" ] || [ "$1" = "-7" ]) && BUILD=7
  ([ "$2" = "7" ] || [ "$2" = "-7" ]) && BUILD=7
  ([ "$3" = "7" ] || [ "$3" = "-7" ]) && BUILD=7

  ([ "$1" = "8" ] || [ "$1" = "-8" ]) && BUILD=8
  ([ "$2" = "8" ] || [ "$2" = "-8" ]) && BUILD=8
  ([ "$3" = "8" ] || [ "$3" = "-8" ]) && BUILD=8
}

# Script Update Function
self_update() {
  echo "Status:"
  cd "$SCRIPTPATH"
  timeout 1s git fetch --quiet
  timeout 1s git diff --quiet --exit-code "origin/$BRANCH" "$SCRIPTFILE"
  [ $? -eq 1 ] && {
    echo "  ✗ Version: Mismatched."
    echo
    echo "Fetching Update:"
    if [ -n "$(git status --porcelain)" ];  # opposite is -z
    then
      git stash push -m 'local changes stashed before self update' --quiet
    fi
    git pull --force --quiet
    git checkout $BRANCH --quiet
    git pull --force --quiet
    echo "  ✓ Update: Complete."
    echo
    echo "Launching New Version. Standby..."
    sleep 3
    cd - > /dev/null                        # return to original working dir
    exec "$SCRIPTNAME" "${ARGS[@]}"

    # Now exit this old instance
    exit 1
    }
  echo "  ✓ Version: Current."
  echo
}

# Package Check/Install Function
packages() {
  #echo "1. Required Packages:"
  install_pkgs=" "
  for keys in "${!PackagesArray[@]}"; do
    REQUIRED_PKG=${PackagesArray[$keys]}
    PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $REQUIRED_PKG|grep "install ok installed")
    if [ "" = "$PKG_OK" ]; then
      echo "  ✗ $REQUIRED_PKG: Not Found."
      install_pkgs+=" $REQUIRED_PKG"
    else
      echo "  ✓ $REQUIRED_PKG: Found."
    fi
  done
  if [ " " != "$install_pkgs" ]; then
  echo
  #echo "1a. Installing Missing Packages:"
  #echo
  #apt --dry-run install $install_pkgs #debug
  apt install -y $install_pkgs
  fi
}

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

  [ $BUILD -eq 7 ] && echo -n " for ARMv7" && [ $STATIC -eq 1 ] && echo " (static)"
  [ $BUILD -eq 8 ] && echo -n " for ARMv8" && [ $STATIC -eq 1 ] && echo " (static)"
  [ $BUILD -eq 0 ] && echo -n " for x86-64" && [ $STATIC -eq 1 ] && echo " (static)"

  echo
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


# Flag Check
flags $1 $2 $3 $4

# Error Trap
trap 'errexit' ERR

# Opening Intro
clear
inoutheader
inoutfooter


#===========================================================================================================================================
### Start Phase 7
PHASE="Script_Self-Update"
phaseheader $PHASE
#===========================================================================================================================================
self_update

### End Phase 7
phasefooter $PHASE

#===========================================================================================================================================
### Start Phase 6
PHASE="Dependancies"
phaseheader $PHASE
#===========================================================================================================================================
apt update
packages

### End Phase 6
phasefooter $PHASE

#===========================================================================================================================================
### Start Phase 5
PHASE="Backup"
phaseheader $PHASE
#===========================================================================================================================================
exit 0

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

#===========================================================================================================================================
### Start Phase 4
PHASE="Setup"
phaseheader $PHASE
#===========================================================================================================================================

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

# Change working dir to clone - Create build folder
[ $DEBUG -eq 1 ] && echo -e "\e[96m++ $PHASE - cd xmrig && mkdir build\e[39m"
cd xmrig && mkdir build

# Building STATIC requires dependancies to be built via provided xmrig script.
if [ $STATIC -eq 1 ]
then
  [ $DEBUG -eq 1 ] && echo -e "\e[96m++ $PHASE - STATIC - cd scripts && ./build_deps.sh and cd ..\e[39m"
  cd scripts && ./build_deps.sh
  cd ..
fi

# Change to build directory
[ $DEBUG -eq 1 ] && echo -e "\e[96m++ $PHASE - cd build\e[39m"
cd build

### End Phase 4
phasefooter $PHASE

#===========================================================================================================================================
### Start Phase 3
PHASE="Compiling/Building"
phaseheader $PHASE
#===========================================================================================================================================
# Setup build enviroment
if [ $STATIC -eq 1 ]
then
  [ $DEBUG -eq 1 ] && [ $BUILD -eq 7 ] && echo -e "\e[96m++ $PHASE - cmake .. -DCMAKE_BUILD_TYPE=Release -DARM_TARGET=7 -DWITH_OPENCL=OFF -DWITH_CUDA=OFF -DWITH_HWLOC=OFF -DWITH_ASM=OFF -DXMRIG_DEPS=scripts/deps\e[39m"
  [ $BUILD -eq 7 ] && cmake .. -DCMAKE_BUILD_TYPE=Release -DARM_TARGET=7 -DWITH_OPENCL=OFF -DWITH_CUDA=OFF -DWITH_HWLOC=OFF -DWITH_ASM=OFF -DXMRIG_DEPS=scripts/deps
  [ $DEBUG -eq 1 ] && [ $BUILD -eq 8 ] && echo -e "\e[96m++ $PHASE - cmake .. -DCMAKE_BUILD_TYPE=Release -DARM_TARGET=7 -DWITH_OPENCL=OFF -DWITH_CUDA=OFF -DWITH_HWLOC=OFF -DWITH_ASM=OFF -DXMRIG_DEPS=scripts/deps\e[39m"
  [ $BUILD -eq 8 ] && cmake .. -DCMAKE_BUILD_TYPE=Release -DARM_TARGET=8 -DWITH_OPENCL=OFF -DWITH_CUDA=OFF -DWITH_HWLOC=OFF -DWITH_ASM=OFF -DXMRIG_DEPS=scripts/deps
  [ $DEBUG -eq 1 ] && [ $BUILD -eq 0 ] && echo -e "\e[96m++ $PHASE - cmake .. -DCMAKE_BUILD_TYPE=Release -DXMRIG_DEPS=scripts/deps\e[39m"
  [ $BUILD -eq 0 ] && cmake .. -DCMAKE_BUILD_TYPE=Release -DXMRIG_DEPS=scripts/deps
else
  [ $DEBUG -eq 1 ] && [ $BUILD -eq 7 ] && echo -e "\e[96m++ $PHASE - cmake .. -DCMAKE_BUILD_TYPE=Release -DARM_TARGET=7 -DWITH_OPENCL=OFF -DWITH_CUDA=OFF -DWITH_HWLOC=OFF -DWITH_ASM=OFF\e[39m"
  [ $BUILD -eq 7 ] && cmake .. -DCMAKE_BUILD_TYPE=Release -DARM_TARGET=7 -DWITH_OPENCL=OFF -DWITH_CUDA=OFF -DWITH_HWLOC=OFF -DWITH_ASM=OFF
  [ $DEBUG -eq 1 ] && [ $BUILD -eq 8 ] && echo -e "\e[96m++ $PHASE - cmake .. -DCMAKE_BUILD_TYPE=Release -DARM_TARGET=7 -DWITH_OPENCL=OFF -DWITH_CUDA=OFF -DWITH_HWLOC=OFF -DWITH_ASM=OFF\e[39m"
  [ $BUILD -eq 8 ] && cmake .. -DCMAKE_BUILD_TYPE=Release -DARM_TARGET=8 -DWITH_OPENCL=OFF -DWITH_CUDA=OFF -DWITH_HWLOC=OFF -DWITH_ASM=OFF
  [ $DEBUG -eq 1 ] && [ $BUILD -eq 0 ] && echo -e "\e[96m++ $PHASE - cmake .. -DCMAKE_BUILD_TYPE=Release\e[39m"
  [ $BUILD -eq 0 ] && cmake .. -DCMAKE_BUILD_TYPE=Release
fi

# Bypass make process if debug is enabled.
if [ $DEBUG -eq 1 ]
then
  echo -e "\e[96m++ $PHASE - touch xmrig\e[39m"
  touch xmrig
else
  make
fi

# End Phase 3
phasefooter $PHASE

#===========================================================================================================================================
### Start Phase 2
PHASE="Compressing/Moving"
phaseheader $PHASE
#===========================================================================================================================================
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

#===========================================================================================================================================
# Start Phase 1
PHASE="Cleanup"
phaseheader $PHASE
#===========================================================================================================================================

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

#===========================================================================================================================================
# Close Out
inoutheader
echo " Folder Location: $SCRIPTPATH/xmrig/"
echo " Bin: $SCRIPTPATH/xmrig/xmrig"
echo " Example Start Script: $SCRIPTPATH/xmrig/start-example.sh"
echo
inoutfooter

# Clean exit of script
exit 0
