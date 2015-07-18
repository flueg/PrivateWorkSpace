#!/bin/bash

source "func-base"

CMD="/usr/share/centrifydc/bin/adproperty -s -n adclient.unit.test.adproperty -d true"
test_ssh $CMD
echo $?
