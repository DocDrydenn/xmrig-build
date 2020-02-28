#!/bin/bash

# Clear screen
clear

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
build=0
VERS="1.4"

if [[ "$1" = "7" ]]
 then
  build=7
fi
if [[ "$1" = "8" ]]
 then
  build=8
fi

echo -e "\e[32m========================================"
echo -e "========================================\e[39m"
echo " XMRig Build Script v$VERS"

if [[ "$build" = "7" ]]
 then
  echo " for ARMv7"
fi
if [[ "$build" = "8" ]]
 then
  echo " for ARMv8"
fi
if [[ "$build" = "0" ]]
 then
  echo " for x86-64"
fi

echo " by DocDrydenn @ getpimp.org"
echo -e "\e[32m========================================"
echo -e "========================================\e[39m"
echo " "
echo -e "\e[32m==================================\e[39m"
echo -e "\e[35m6. Verifiing/Installing Tools..."
echo -e "\e[32m==================================\e[39m"

# Install required tools for building from source
 apt install git build-essential cmake libuv1-dev libssl-dev libhwloc-dev screen p7zip-full -y

# Install optional tools apt install htop nano -y
# apt install htop nano

echo -e "\e[32m==================================\e[39m"
echo -e "\e[35m Completed"
echo -e "\e[32m==================================\e[39m"
echo " "
echo -e "\e[32m==================================\e[39m"
echo -e "\e[35m5. Backup..."
echo -e "\e[32m==================================\e[39m"
if [ -d "$SCRIPTPATH/xmrig" ]
 then
  if [ -f "$SCRIPTPATH/xmrig/xmrig-build.7z.bak" ]
   then
    # Remove last backup archive
     echo "xmrig-build.7z.bak removed"
     rm $SCRIPTPATH/xmrig/xmrig-build.7z.bak
   else
    echo "xmrig-build.7z.bak doesn't exist - Skipping Delete..."
  fi
  if [ -f "$SCRIPTPATH/xmrig/xmrig.bak" ]
   then
    # Remove last backup binary
     echo "xmrig.bak removed"
     rm $SCRIPTPATH/xmrig/xmrig.bak
   else
    echo "xmrig.bak doesn't exist - Skipping Delete..."
  fi
  if [ -f "$SCRIPTPATH/xmrig/xmrig-build.7z" ]
   then
    # Backup last archive
     echo "xmrig-build.7z renamed to xmrig-build.7z.bak"
     mv $SCRIPTPATH/xmrig/xmrig-build.7z $SCRIPTPATH/xmrig/xmrig-build.7z.bak
   else
    echo "xmrig-build.7z doesn't exist - Skipping Backup..."
  fi
  if [ -f "$SCRIPTPATH/xmrig/xmrig" ]
   then
    # Backup last binary
     echo "xmrig renamed to xmrig.bak"
     mv $SCRIPTPATH/xmrig/xmrig $SCRIPTPATH/xmrig/xmrig.bak
   else
    echo "xmrig doesn't exist - Skipping Backup..."
  fi
 else
 # Make xmrig folder if it doesn't exist
  echo "Creating xmrig directory..."
  mkdir -p $SCRIPTPATH/xmrig
fi

echo -e "\e[32m==================================\e[39m"
echo -e "\e[35m Completed"
echo -e "\e[32m==================================\e[39m"
echo " "
echo -e "\e[32m==================================\e[39m"
echo -e "\e[35m4. Setting Up Source..."
echo -e "\e[32m==================================\e[39m"

# Enable Error exiting of this script from this point on
 set -e

if [ -d "$SCRIPTPATH/_source" ]
 then
  # Old source folder found. Remove it.
   rm -r $SCRIPTPATH/_source
fi

# Make new source folder
 mkdir $SCRIPTPATH/_source

# Change working dir to source folder
 cd $SCRIPTPATH/_source

# Clone XMRig from github into source folder
 git clone https://github.com/xmrig/xmrig.git

# Change working dir to clone - Create build folder - Change working dir to build folder
 cd xmrig && mkdir build && cd build

echo -e "\e[32m==================================\e[39m"
echo -e "\e[35m Completed"
echo -e "\e[32m==================================\e[39m"
echo " "
echo -e "\e[32m==================================\e[39m"
echo -e "\e[35m3. Building..."
echo -e "\e[32m==================================\e[39m"

# Setup build enviroment
if [[ "$build" = "7" ]]
 then
  cmake .. -DCMAKE_BUILD_TYPE=Release -DARM_TARGET=7 -DWITH_OPENCL=OFF -DWITH_CUDA=OFF -DWITH_HWLOC=OFF -DWITH_ASM=OFF
  make -j 4 --environment-overrides --keep-going
fi
if [[ "$build" = "8" ]]
 then
  cmake .. -DCMAKE_BUILD_TYPE=Release -DARM_TARGET=8 -DWITH_OPENCL=OFF -DWITH_CUDA=OFF -DWITH_HWLOC=OFF -DWITH_ASM=OFF
  make -j 4 --environment-overrides --keep-going
fi
if [[ "$build" = "0" ]]
 then
  cmake .. -DCMAKE_BUILD_TYPE=Release
  make
fi

# Debug - Skip Build
# touch xmrig

echo -e "\e[32m==================================\e[39m"
echo -e "\e[35m Completed"
echo -e "\e[32m==================================\e[39m"
echo " "
echo -e "\e[32m==================================\e[39m"
echo -e "\e[35m2. Compressing and Moving..."
echo -e "\e[32m==================================\e[39m"

# Compress built xmrig into archive
 7z a xmrig-build.7z $SCRIPTPATH/xmrig

# Copy archive to xmrig folder
 cp xmrig-build.7z $SCRIPTPATH/xmrig/xmrig-build.7z

# Copy built xmrig to xmrig folder
 cp $SCRIPTPATH/_source/xmrig/build/xmrig $SCRIPTPATH/xmrig/xmrig

echo -e "\e[32m==================================\e[39m"
echo -e "\e[35m Completed."
echo -e "\e[32m==================================\e[39m"
echo " "
echo -e "\e[32m==================================\e[39m"
echo -e "\e[35m1. Cleaning Up..."
echo -e "\e[32m==================================\e[39m"

# Change working dir back to root
 cd $SCRIPTPATH

# Remove source folder
 echo "Source directory removed."
 rm -r _source

# Create start-example.sh
if [ ! -f "$SCRIPTPATH/xmrig/start-example.sh" ]
 then
  echo "start-example.sh created."

cat > $SCRIPTPATH/xmrig/start-example.sh <<EOF
#! /bin/bash

screen -wipe
screen -dm $SCRIPTPATH/xmrig/xmrig -o <pool_IP>:<pool_port> -l /var/log/xmrig-cpu.log --donate-level 1 --rig-id <rig_name>
screen -r
EOF

  # Make start-example.sh executable
  echo "start-example.sh made executable."
  chmod +x $SCRIPTPATH/xmrig/start-example.sh
fi

echo -e "\e[32m==================================\e[39m"
echo -e "\e[35m Completed\e[39m"
echo -e "\e[32m==================================\e[39m"
echo " "
echo -e "\e[32m========================================"
echo -e "========================================\e[39m"
echo " XMRig Build Script v$VERS"

if [[ "$build" = "7" ]]
 then
  echo " for ARMv7"
fi
if [[ "$build" = "8" ]]
 then
  echo " for ARMv8"
fi
if [[ "$build" = "0" ]]
 then
  echo " for x86-64"
fi

echo " by DocDrydenn @ getpimp.org"
echo " "
echo " Folder Location: $SCRIPTPATH/xmrig/"
echo " Bin: $SCRIPTPATH/xmrig/xmrig"
echo " Example Start Script: $SCRIPTPATH/xmrig/start-example.sh"
echo " "
echo -e "\e[32m========================================"
echo -e "========================================\e[39m"

# Clean exit of script
 exit 0
