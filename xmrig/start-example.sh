#! /bin/bash

screen -wipe
screen -dm /root/xmrig-build/xmrig/xmrig -o <pool_IP>:<pool_port> -l /var/log/xmrig-cpu.log --donate-level 1 --rig-id <rig_name> -k --verbose
screen -r
