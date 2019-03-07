#!/bin/bash

if [ $# -le 1 ] 
then 
    echo "Usage: ./test.sh 50 test.log"
    exit 1
fi 

xcodebuild install -alltargets

counter=1
while [ $counter -le $1 ]
do
    echo $counter
    ios-deploy -d -m -W -I -b /tmp/argue-with-ar-ios.dst/Applications/argue-with-ar-ios.app | grep XXXXXXX* >> $2
    ((counter++))
done

# Converting greppy output to CSV format
tr -d '\n\r' < $2 > temp.log && mv temp.log $2
sed -e "s/XXXXXXX: /,/g" -e "s/,//" $2 > temp.log && mv temp.log $2

while true; do
    say "ICH BIN FERTIG. GIB MIR WAS NEUES ZU TUN"
done