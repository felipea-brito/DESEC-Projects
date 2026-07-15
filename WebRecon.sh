#!/bin/bash

read -p "Type the domain: " domain
read -p "Type one for direcotry research and two for a file [1] [2]: " option

  if [[ $option == 1 ]]; then
    
    for directory in $(cat directory.txt);
    
    do
      response=$(curl -s -H "User-Agent: DesecTool" -o /dev/null -w "%{http_code}" "$domain/$direcotry/")
    
      if [[ $response == "200" ]]; then
        echo "Directory discovered: $domain/$word"
      fi
    done
    
  elif [[ $option == 2 ]]; then

    read -p "Type the extension: " extension
    
    for word in $(cat word.txt);
    
    do
      response=$(curl -s -H "User-Agent: DesecTool" -o /dev/null -w "%{http_code}" "$domain/$word.$extension")
    
      if [[ $response == "200" ]]; then
        echo "File discovered: $word.$extension"
      fi
    done

  else
    echo "Don't have this option"
  fi
