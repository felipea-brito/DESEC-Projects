#!/bin/bash

echo "Type the website address: "
read website

wget $website

grep href index.html | cut -d "/" -f 3 | grep "\." | cut -d '"' -f 1 | grep -v "<l" > result
for url in $(cat result); do host $url | grep "has address"; done
