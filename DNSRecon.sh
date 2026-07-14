#!/bin/bash

read -p "Is it a reverse or direct search, type 1 or 2: " verify

if [[ $verify == 2 ]]; then

  read -p "Type the domain to verify: " domain
  
  for word in $(cat n0kovo_subdomains.txt);
  do
    host $word.$domain | grep -v "NXDOMAIN"
  done

elif [[ $verify == 1 ]]; then
  
  read -p "Type the IP do verify: " ip
  read -p "Type the range to verify: " range
  
  for range in $(seq "$range");
  do
    host -t ptr $ip.$range | grep -v "$ip"
  done
else
  echo "Inform correct option."
fi
