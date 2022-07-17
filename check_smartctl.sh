#!/bin/bash

# ----------------------------------------------------------------------------------
#
# Script for checking for the SmartCtl status of an HDD. The results is sent back to
# https://healthchecks.io/
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
#  > check_smartctl.sh [device] [health_check_key]
#
# Example : 
#  > check_smartctl.sh /dev/sda 00000000-0000-0000-0000-000000000000
# 
# ----------------------------------------------------------------------------------


SMARTCTL=`/usr/sbin/smartctl -d ata -H $1 | grep PASSED`

if [ -z "$SMARTCTL" ];
   then
      RETCODE="/fail"
   else
      RETCODE=""
fi

curl -fsS --retry 3 -X POST -H "Content-Type: application/json" "https://hchk.io/$2$RETCODE" >/dev/null 2>&1
