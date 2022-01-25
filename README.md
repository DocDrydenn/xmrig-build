# xmrig-build.sh
Simple automated script to build XMRig *(dynamic or static)* from source on x86-64, ARMv7, and ARMv8 devices. 

**Note: Builds are for CPU's. No GPU libraries are built.**

I made it to speed up my process for installing and updating XMRig on multiple devices.

Should work for just about any device running a Debian-based Linux.

I've tested on the following with success:
- Ubuntu 18.04 *(Bionic)* [x86-64] [ARMv7] [ARMv8]
- Ubuntu 20.04 *(Focal)* [x86-64] [ARMv7] [ARMv8]
- Debian 9 *(Stretch)* [x86-64]
- Debian 10 *(Buster)* [x86-64]
- Raspbian *(Stretch)* [ARMv7] [ARMv8]
- Armbian *(Stretch)* [ARMv7] [ARMv8]

* Fails on Raspbian *(Buster)* and Raspberry Pi OS... I am unable to determine exactly why.

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
Upon completion, this script will create a directory `./scriptpath/xmrig` and will have the following files inside:
- xmrig - XMRig binary
- start-example.sh - Example XMRig startup script
- xmrig-build.7z - 7zip archive of above files for easy "transport" to a new machine/location.

If this script has been run in the past, prior to building a new binary, it will make a backups of the previous XMRig build resulting in two additional files inside the `xmrig` directory.
- xmrig.bak - previous XMRig binary
- xmrig-build.7z.bak - previous XMRig backup archive

## Screenshot:
![Screenshot 2022-01-24 202425](https://user-images.githubusercontent.com/48564375/150893727-af9d5d0e-3d48-4519-aad0-f7cf5cb34661.png)
