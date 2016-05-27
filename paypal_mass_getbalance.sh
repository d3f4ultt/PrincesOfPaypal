#!/bin/bash
if [ $# -eq 1 ]
then
    awk -F , '{print "\033[1;31m# "$1"\033[0m "}{system("curl --insecure https://api-3t.paypal.com/nvp -d \"USER="$1"&PWD="$2"&SIGNATURE="$3"&VERSION=90&METHOD=GetBalance&RETURNALLCURRENCIES=1\"")}{print""}' $1
fi
