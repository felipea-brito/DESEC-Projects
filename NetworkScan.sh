#!/bin/bash

for i in $(seq 1 11)
do
    echo "\n[+] Ouvindo o canal $i\n"
    sudo ip link set wlan0 down
    sudo iw dev wlan0 set channel $i
    sudo ip link set wlan0 up
    sleep 2
    sudo ip link set wlan0 down
    sudo iw dev wlan0 set type monitor
    sudo iw dev wlan0 set monitor control otherbss
    sudo ip link set wlan0 up
    sleep 2
    tcpdump -vv -i wlan0 -n -c 5 | grep "Beacon" | awk '{print $12, - CH $24}'
done
