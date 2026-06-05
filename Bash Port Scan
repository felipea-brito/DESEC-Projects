#!/bin/bash

if [ "$1" == "" ]
then
    echo "How to use: $0 Network Port"
else
for ip in {1..254};
do
hping3 -S -p $2 -c 1 $1.$ip 2> /dev/null | grep "flags=SA" | cut -d " " -f 2;
done
fi
