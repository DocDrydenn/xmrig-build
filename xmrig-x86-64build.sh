#!/bin/bash

# Clear screen
clear

echo -e "\e[32m========================================"
echo -e "========================================\e[39m"
echo -e " XMRig Build Script for x86-64 v1.0"
echo -e "         by DocDrydenn @ getpimp.org"
echo -e "\e[32m========================================"
echo -e "========================================\e[39m"

echo " "
echo -e "\e[32m==================================\e[39m"
echo -e "\e[35m6. Backup of Current..."
echo -e "\e[32m==================================\e[39m"

if [ -d "/root/xmrig" ]
 then
  if [ -f "/root/xmrig/xmrig-build.7z.bak" ]
   then
    # Remove last backup archive
     echo "xmrig-build.7z.bak removed"
     rm /root/xmrig/xmrig-build.7z.bak
   else
    echo "xmrig-build.7z.bak doesn't exist - Skipping Delete..."
  fi
  if [ -f "/root/xmrig/xmrig.bak" ]
   then
    # Remove last backup binary
     echo "xmrig.bak removed"
     rm /root/xmrig/xmrig.bak
   else
    echo "xmrig.bak doesn't exist - Skipping Delete..."
  fi
  if [ -f "/root/xmrig/xmrig-build.7z" ]
   then
    # Backup last archive
     echo "xmrig-build.7z renamed to xmrig-build.7z.bak"
     mv /root/xmrig/xmrig-build.7z /root/xmrig/xmrig-build.7z.bak
   else
    echo "xmrig-build.7z doesn't exist - Skipping Backup..."
  fi
  if [ -f "/root/xmrig/xmrig" ]
   then
    # Backup last binary
     echo "xmrig renamed to xmrig.bak"
     mv /root/xmrig/xmrig /root/xmrig/xmrig.bak
   else
    echo "xmrig doesn't exist - Skipping Backup..."
  fi
 else
 # Make xmrig folder if it doesn't exist
  echo "Creating xmrig directory..."
  mkdir -p /root/xmrig
fi

echo -e "\e[32m==================================\e[39m"
echo -e "\e[35m Completed"
echo -e "\e[32m==================================\e[39m"
echo " "
echo -e "\e[32m==================================\e[39m"
echo -e "\e[35m5. Verifiing/Installing Tools..."
echo -e "\e[32m==================================\e[39m"

# Install required tools for building from source
 apt install git build-essential cmake libuv1-dev libssl-dev libhwloc-dev screen p7zip-full -y

# Install optional tools
# apt install htop nano -y

echo -e "\e[32m==================================\e[39m"
echo -e "\e[35m Completed"
echo -e "\e[32m==================================\e[39m"
echo " "
echo -e "\e[32m==================================\e[39m"
echo -e "\e[35m4. Setting Up Source..."
echo -e "\e[32m==================================\e[39m"

# Enable Error exiting of this script from this point on
 set -e

if [ -d "/root/_source" ]
 then
  # Old source folder found. Remove it.
   rm -r /root/_source
fi

# Make new source folder
 mkdir /root/_source

# Change working dir to source folder
 cd /root/_source

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

# Setup build enviroment for ARMvX
 cmake ..

# Build
 make

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
 7z a xmrig-build.7z /root/xmrig

# Copy archive to xmrig folder
 cp xmrig-build.7z /root/xmrig/xmrig-build.7z

# Copy built xmrig to xmrig folder
 cp /root/_source/xmrig/build/xmrig /root/xmrig/xmrig

echo -e "\e[32m==================================\e[39m"
echo -e "\e[35m Completed."
echo -e "\e[32m==================================\e[39m"
echo " "
echo -e "\e[32m==================================\e[39m"
echo -e "\e[35m1. Cleaning Up..."
echo -e "\e[32m==================================\e[39m"

# Change working dir back to root
 cd /root

# Remove source folder
echo "Source directory removed."
rm -r _source

# Create start-example.sh
if [ ! -f "/root/xmrig/start-example.sh" ]
   then
echo "start-example.sh created."
cat > /root/xmrig/start-example.sh <<EOF
#! /bin/bash
screen -wipe
screen -dm /root/xmrig/xmrig -o <pool_IP>:<pool_port> -l /var/log/xmrig-cpu.log --donate-level 1 --rig-id <rig_name>
screen -r
EOF

# Make start-example.sh executable
 echo "start-example.sh made executable."
 chmod +x /root/xmrig/start-example.sh
fi

echo -e "\e[32m==================================\e[39m"
echo -e "\e[35m Completed\e[39m"
echo -e "\e[32m==================================\e[39m"
echo " "
echo -e "\e[32m========================================"
echo -e "========================================\e[39m"
echo -e " XMRig Build Script for x86-64 v1.0"
echo -e "         by DocDrydenn @ getpimp.org"
echo -e " "
echo "  Folder Location: /root/xmrig/"
echo "  Bin: /root/xmrig/xmrig"
echo "  Example Start Script: /root/xmrig/start-example.sh"
echo " "
echo -e "\e[32m========================================"
echo -e "========================================\e[39m"

# Clean exit of script
 exit 0
