#!/bin/bash

for word in $(cat list.txt);
do
    host -t cname $word.$1 | grep "alias for"
done
