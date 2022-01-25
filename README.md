# xmrig-build.sh
Simple automated script to build XMRig *(dynamic or static)* from source on x86-64, ARMv7, and ARMv8 devices. 

**Note: Builds are for CPU's. No GPU libraries are built.**

I made it to speed up my process for installing and updating XMRig on multiple devices.

Should work for just about any device running a Debian-based Linux.

I've tested on the following with success:
<<<<<<< HEAD
- Ubuntu 18.04 *(Bionic)* [x86-64] [ARMv7] [ARMv8]
- Ubuntu 20.04 *(Focal)* [x86-64] [ARMv7] [ARMv8]
- Debian 9 *(Stretch)* [x86-64]
- Debian 10 *(Buster)* [x86-64]
- Raspbian *(Stretch)* [ARMv7] [ARMv8]
- Armbian *(Stretch)* [ARMv7] [ARMv8]

* Fails on Raspbian *(Buster)* and Raspberry Pi OS... I am unable to determine exactly why.

## Issues:
Feel free to raise issues you might find with my script, however, it must be noted that failures during the actual xmrig build process are outside of this script's control.

This script uses the exact build processes documented by XMRig. All build failure issues should be directed to the XMRig's Git.

I have seen times where a dynamic build fails, but a static build will pass (and vice versa). I've seen builds pass for one XMRig version and fail for another... it all depends on what's going on over at the XMRig repo.

## Requirements:
This script will check for and install *(via apt)* the following packages/tools:

`build-essential, cmake, ibuv1-dev, libssl-dev, libhwloc-dev, screen, p7zip-full`

Not checked or installed via script:

`Git` *(needed for the install and self-update process to work.)*

## Install:
This script is self-updating. The self-update routine uses git commands to make the update.

`git clone https://github.com/DocDrydenn/svr_fans.git`

*(Future update will allow the user to skip the self-update function... allowing the script to be "installed" and/or run from outside of a git clone.)*

## Usage:
```
 ./xmrig-build [-dhs] -<0|7|8>

    -0 | 0 | <blank>      - x86-64
    -7 | 7                - ARMv7
    -8 | 8                - ARMv8

    -s | s                - Build Static

    -h | h                - Display (this) Usage Output
    -d | d                - Enable Debug Output (Simulation-Only)

```
### Examples
#### x86-64 (Default)
`./xmrig-build.sh` (No argument or anything other than `7` and `8`)

#### ARMv7
`./xmrig-build.sh 7`

#### ARMv8 Static Binary
`./xmrig-build.sh 8 -s`

## Result:
Upon completion, this script will create a directory `./$scriptpath/xmrig` and will have the following files inside:
- xmrig - XMRig binary
- start-example.sh - Example XMRig startup script
- xmrig-build.7z - 7zip archive of above files for easy "transport" to a new machine/location.

If this script has been run in the past, prior to building a new binary, it will make backups of the previous XMRig build files resulting in two additional files inside the `xmrig` directory, just incase one might need to revert to a previous build *(see Issues section above)*. 
- xmrig.bak - previous XMRig binary
- xmrig-build.7z.bak - previous XMRig backup archive

**Note: This "backup" function is rolling... meaning each run of the script will push off the last. If you wish to keep the backups, I suggest you copy them to another location prior to re-running the script.**

## Screenshot:
![Screenshot 2022-01-24 202425](https://user-images.githubusercontent.com/48564375/150893727-af9d5d0e-3d48-4519-aad0-f7cf5cb34661.png)
=======
- Ubuntu 18.04 (Bionic) [x86-64] [ARMv7] [ARMv8]
- Ubuntu 20.04 (Focal) [x86-64] [ARMv7] [ARMv8]
- Debian 9 (Stretch) [x86-64]
- Debian 10 (Buster) [x86-64]
- Raspbian (Stretch) [ARMv7] [ARMv8]
- Armbian (Stretch) [ARMv7] [ARMv8]

* Fails on Raspbian (Buster) and Raspberry Pi OS... I am unable to determine exactly why.

![Screenshot 2022-01-24 202425](https://user-images.githubusercontent.com/48564375/150893375-7f8f8623-3a83-4a25-93c8-8b824329a559.png)


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
>>>>>>> de5678576ec3f87a4e5a1f3165b6ce7cfcd8c9f3
