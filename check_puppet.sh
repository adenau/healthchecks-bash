#!/bin/bash

# ----------------------------------------------------------------------------------
#
# Script for checking that Puppet has ran sucessfully in the last hour. The results 
# is sent back to https://healthchecks.io/
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
#  > check_puppet.sh [health_check_key]
#
# Example : 
#  > check_puppet.sh 00000000-0000-0000-0000-000000000000
# 
# ----------------------------------------------------------------------------------

PATH=$PATH:/opt/puppetlabs/bin

PUPPET_VAR_DIR=`puppet config print vardir`

RECENT_REPORT=`find $PUPPET_VAR_DIR/state/last_run_report.yaml -mmin -61 -print`
CONTENT_SUMMARY=`cat $PUPPET_VAR_DIR/state/last_run_report.yaml | grep -A 3 'level: err'`

if [ ! -z $RECENT_REPORT ];
then

  if grep -xqFe "failed: true" $RECENT_REPORT;
  then
    curl -fsS --retry 3 -X POST -H "Content-Type: application/json" -d "{'msg':'Summary has errors. $CONTENT_SUMMARY',}" "https://hchk.io/$1/fail" >/dev/null 2>&1
  else
    curl -fsS --retry 3 -X POST -H "Content-Type: application/json" "https://hchk.io/$1" >/dev/null 2>&1
  fi

else 
å
  curl -fsS --retry 3 -X POST -H "Content-Type: application/json" -d "{'msg':'Can't find puppet summary in last hour. $RECENT_REPORT',}" "https://hchk.io/$1/fail" >/dev/null 2>&1
fi



