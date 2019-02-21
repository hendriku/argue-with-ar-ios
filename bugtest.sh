#!/bin/bash

xcodebuild install -alltargets

counter=1
while [ $counter -le $1 ]
do
    echo $counter
    ios-deploy -d -m -W -I -b /tmp/argue-with-ar-ios.dst/Applications/argue-with-ar-ios.app | grep XXXXXXX* >> test.log
    ((counter++))
done

while true; do
    say "ALARM"
done