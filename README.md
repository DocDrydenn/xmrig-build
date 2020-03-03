# xmrig-build
Simple automated script to build XMRig from source on x86-64, ARMv7, and ARMv8 devices.

Should work for just about any device running a Debian-based Linux.

![Alt text](/xmrig-armbuild.JPG?raw=true "Screenshot")

### x86-64 (Default)
Usage: `./xmrig-build.sh` (No argument or anything other than `7` and `8`)

### ARMv7 & ARMv8
Usage: `./xmrig-build.sh #` 
(where `#` is a required argument. `7` for ARMv7 or `8` for ARMv8)

## What Does This Script Do?

#### Dependancies...
- apt update && apt upgrade -y
- apt install git build-essential cmake libuv1-dev libssl-dev libhwloc-dev screen p7zip-full -y

#### Backup...
- rm /root/xmrig/xmrig-build.7z.bak
- rm /root/xmrig/xmrig.bak
- mv /root/xmrig/xmrig-build.7z /root/xmrig/xmrig-build.7z.bak
- mv /root/xmrig/xmrig /root/xmrig/xmrig.bak

#### Setup...
- mkdir /root/_source
- cd /root/_source
- git clone https://github.com/xmrig/xmrig.git
- cd xmrig && mkdir build && cd build

#### Compiling/Building...
- For ARMv7 and ARMv8 - cmake .. -DCMAKE_BUILD_TYPE=Release -DARM_TARGET=7 -DWITH_OPENCL=OFF -DWITH_CUDA=OFF -DWITH_HWLOC=OFF -DWITH_ASM=OFF
- For x86-64 - cmake .. -DCMAKE_BUILD_TYPE=Release
- make

#### Compressing/Moving...
- 7z a xmrig-build.7z /root/xmrig
- cp xmrig-build.7z /root/xmrig/xmrig-build.7z
- cp /root/_source/xmrig/build/xmrig /root/xmrig/xmrig

#### Cleanup...
- cd /root
- rm -r _source

Upon successful completion of this script, you should end up with an `xmrig` directory with the following contents:
1. `xmrig` - XMRig binary
2. `start-example.sh` - Example start script.
3. `xmrig-build.7z` - 7zip archive of file #1 and file #2
4. *`xmrig.bak` - Backup of last `xmrig` binary
5. *`xmrig-build.7z.bak` - Backup of last `xmrig-build.7z` archive.

*Note: File #4 and file #5 will only exist after running this script at least twice.
