#!/bin/bash

cmd="/home/flueg/Centrify/build/Suite/DC/unix/cli/adproperty -s multi.threads.test"
cmd_g="/home/flueg/Centrify/build/Suite/DC/unix/cli/adproperty -g multi.threads.test"
while true
do
for i in {1..10}
do
    (while true; do echo "Process $i received running..."; ${cmd} -d "val$i" -V; ${cmd_g} -V; sleep 5; break; done) &
done
sleep 10
done
