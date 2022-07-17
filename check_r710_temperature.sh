#!/bin/bash

# ----------------------------------------------------------------------------------
#
# Script for checking the temperature reported by the ambient temperature sensor of. 
# a poweredge server is too high. The results is sent back to https://healthchecks.io/
#
# Copyright (c) 2022 Alexandre Denault
#
# MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# Usage :
#  > check_r710_temperature.sh [host] [health_check_key]
#
# Example : 
#  > check_r710_temperature.sh 192.168.1.2 00000000-0000-0000-0000-000000000000
#
# Inspired / derivation of : 
#   https://github.com/NoLooseEnds/Scripts/blob/master/R710-IPMI-TEMP/R710-IPMITemp.sh
# 
# ----------------------------------------------------------------------------------


# IPMI SETTINGS:
# Modify to suit your needs.
IPMIHOST=$1
IPMIUSER=root
IPMIPW=calvin

# TEMPERATURE
# Change this to the temperature in celcius you are comfortable with.
# If the temperature goes above the set degrees it will send raw IPMI command to enable dynamic fan control
MAXTEMP=30

# This variable sends a IPMI command to get the temperature, and outputs it as two digits.
# Do not edit unless you know what you do.
TEMP=$(ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW sdr type temperature |grep Ambient |grep degrees |grep -Po '\d{2}' | tail -1)

if [[ $TEMP > $MAXTEMP ]];
  then
    #echo "Warning: Temperature is too high on $IPMIHOST! Activating dynamic fan control! ($TEMP C)" 
    ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW raw 0x30 0x30 0x01 0x01
    curl -fsS --retry 3 -X POST -H "Content-Type: application/json" -d "{'temp':$TEMP, 'msg':'Temperature too high!'}" "https://hchk.io/$2/fail" >/dev/null 2>&1
  else
    # healthchecks.io
    curl -fsS --retry 3 -X POST -H "Content-Type: application/json" -d "{'temp':$TEMP}" "https://hchk.io/$2" >/dev/null 2>&1
fi
