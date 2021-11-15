# xmrig-build
Simple automated script to build XMRig (dynamic or static) from source on x86-64, ARMv7, and ARMv8 devices. 

I made it to speed up the my process for my installing and updating XMRig on my devices.

Should work for just about any device running a Debian-based Linux.

I've tested on the following with success:
- Ubuntu 18.04 (Bionic) [x86-64] [ARMv7] [ARMv8]
- Ubuntu 20.04 (Focal) [x86-64] [ARMv7] [ARMv8]
- Debian 9 (Stretch) [x86-64]
- Raspbian (Stretch) [ARMv7] [ARMv8]
- Armbian (Stretch) [ARMv7] [ARMv8]

* Fails on Raspbian (Buster) and Raspberry Pi OS... I am unable to determine exactly why.

![Alt text](/xmrig-build.jpg?raw=true "Screenshot")

### Flags
- `-h` will show script USAGE output
- `-d` will give DEBUG output (and bypass the building process) [This will not make a working binary and is only for troubleshooting the rest of the script.]
- `-s` will attempt to build a STATIC binary (see list above for confirmed working OS's)

### x86-64 (Default)
Usage: `./xmrig-build.sh` (No argument or anything other than `7` and `8`)

### ARMv7 & ARMv8
Usage: `./xmrig-build.sh #` 
(where `#` is a `7` for ARMv7 or `8` for ARMv8)

## What Does This Script Do?

[NOTE: The below is from early versions and isn't updated to the current release. I have no plans to keep this part up-to-date, however, I'm leaving this here to give the overall idea of what the script does. Please review the actual release script for the exact specifics.]

#### Dependancies...
- apt update && apt upgrade -y
- apt install git build-essential cmake libuv1-dev libssl-dev libhwloc-dev screen p7zip-full -y

#### Backup...
- rm ./xmrig/xmrig-build.7z.bak
- rm ./xmrig/xmrig.bak
- mv ./xmrig/xmrig-build.7z ./xmrig/xmrig-build.7z.bak
- mv ./xmrig/xmrig ./xmrig/xmrig.bak

#### Setup...
- mkdir ./_source
- cd ./_source
- git clone https://github.com/xmrig/xmrig.git
- cd xmrig && mkdir build && cd build

#### Compiling/Building...
- For ARMv7 - cmake .. -DCMAKE_BUILD_TYPE=Release -DARM_TARGET=7 -DWITH_OPENCL=OFF -DWITH_CUDA=OFF -DWITH_HWLOC=OFF -DWITH_ASM=OFF
- For ARMv8 - cmake .. -DCMAKE_BUILD_TYPE=Release -DARM_TARGET=8 -DWITH_OPENCL=OFF -DWITH_CUDA=OFF -DWITH_HWLOC=OFF -DWITH_ASM=OFF
- For x86-64 - cmake .. -DCMAKE_BUILD_TYPE=Release
- make

#### Compressing/Moving...
- 7z a xmrig-build.7z ./xmrig
- cp xmrig-build.7z ./xmrig/xmrig-build.7z
- cp ./_source/xmrig/build/xmrig ./xmrig/xmrig

#### Cleanup...
- cd ./
- rm -r _source

Upon successful completion of this script, you should end up with an `xmrig` directory with the following contents:
1. `xmrig` - XMRig binary
2. `start-example.sh` - Example start script.
3. `xmrig-build.7z` - 7zip archive of file #1 and file #2
4. *`xmrig.bak` - Backup of last `xmrig` binary
5. *`xmrig-build.7z.bak` - Backup of last `xmrig-build.7z` archive.

*Note: File #4 and file #5 will only exist after running this script at least twice.
