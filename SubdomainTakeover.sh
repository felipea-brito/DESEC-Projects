#!/bin/bash

for word in $(cat '/usr/share/wordlists/seclists/Discovery/DNS/subdomains-top1million-110000.txt');
do
    host -t cname $word.$1 | grep "alias for"
done
