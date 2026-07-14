#!/bin/bash

echo "Type the domain to verify: "
read domain

for word in $(cat n0kovo_subdomains.txt);
do
  host $word.$domain | grep -v "NXDOMAIN"
done
