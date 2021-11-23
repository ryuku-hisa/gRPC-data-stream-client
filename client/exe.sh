#!/bin/bash

size=$1
echo "File size: $size Kbytes"
echo
echo "Making file ..."
dd if=/dev/zero of=$(size)Kbytes.mp4 bs=1K count=$size
echo DONE
TIMEFORMAT='%2R sec'
echo 
echo Sending...
(time go run main.go $(size)Kbytes.mp4) > ./time/out.txt 2>&1
echo DONE
time= $(cat ./time/out.txt)
cat ./time/out.txt >> ./time/time.txt
echo
#rm $sizeKbytes.mp4
echo "Removed Sent file"
echo

printf %s "(size,time) = "
printf %s "($size Kbytes, $time)"
echo
unset TIMEFORMAT
rm ./time/out.txt
echo -e '\033[32m ALL PROCESS DONE \033[m '
