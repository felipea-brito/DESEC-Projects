#!/bin/bash

for word in $(cat '/usr/share/wordlists/seclists/Discovery/DNS/subd>
do
    host -t cname $word.$1 | grep "alias for"
done
