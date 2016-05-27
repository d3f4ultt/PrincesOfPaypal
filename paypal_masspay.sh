#!/bin/bash
if [ $# -eq 4 ]
then
    awk -v email="$2" -v money="$3" -v devise="$4" -F , '{system("curl --insecure https://api-3t.paypal.com/nvp -d \"USER="$1"&PWD="$2"&SIGNATURE="$3"&METHOD=MassPay&VERSION=90&RECEIVERTYPE=EmailAddress&CURRENCYCODE="devise"&L_EMAIL0="email"&L_AMT0="money"\"")}{print""}' $1
fi
