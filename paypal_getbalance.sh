#!/bin/bash
USER=
PWD=
SIGNATURE=
curl --insecure https://api-3t.paypal.com/nvp -d "USER="$USER"&PWD="$PWD"&SIGNATURE="$SIGNATURE"&VERSION=63&METHOD=GetBalance&RETURNALLCURRENCIES=1"