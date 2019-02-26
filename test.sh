#!/bin/bash

xcodebuild install -alltargets

counter=1
while [ $counter -le $1 ]
do
    echo $counter
    ios-deploy -d -m -W -I -b /tmp/argue-with-ar-ios.dst/Applications/argue-with-ar-ios.app | grep XXXXXXX* >> test.log
    ((counter++))
done

# Converting greppy output to CSV format
tr -d '\n\r' < test.log > temp.log && mv temp.log test.log
sed -e "s/XXXXXXX: /,/g" -e "s/,//" test.log > temp.log && mv temp.log test.log

while true; do
    say "ICH BIN FERTIG. GIB MIR WAS NEUES ZU TUN"
done