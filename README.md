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

First, it looks for a command line argument of `7` or `8` to indicate ARMv7 or ARMv8. If nothing (or anything other than `7` and `8`) is found, the script defaults to x86-64. Next, it runs through the following 6 stages using the current directory:
1. Dependancy Check - 
2. Backup - Check if the `xmrig` directory exists (and creates it if it doesn't). Delete any old backup files (`~/xmrig/xmrig.bak` and `~/xmrig/xmrig-build.7z.bak`) then renames the current files (`xmrig` binary and `xmrig-build.7z` archive) with a `.bak` extension making them the new backup files. 
3. 
