#!/bin/bash

# USAGE
# ./exe.sh <filesize> <isAttack>

if [ $# -ne 2 ]; then
  echo "ERROR: sepcify the args"
  echo "Usage: ./exe.sh <isAttack> <filesize>"
  exit 1
fi

isAttack=$1
size=$2

if test $isAttack != "0" -a $isAttack != "1"; then
  echo "Usage: ./exe.sh <isAttack> <filesize> "
  exit 2
fi

echo "File size: $size Mbytes"
echo
echo "Making file ..."
dd if=/dev/zero of="data.mp4" bs=1M count=$size
echo DONE

expect <<EOF
set timeout 10
spawn ssh hisa@192.168.15.30 -p 12150
expect ">> "
send "echo 'hogehoge' | nohup sudo -S tcpdump src host 192.168.15.32 and port 50051 or dst host 192.168.15.32 and port 50051 -w ~/logs/$i.pcap > /dev/null 2>&1 & \n"
expect ">> "
send "exit\n"
EOF
exit 0

TIMEFORMAT='%3R'
echo 
echo Sending...
(time go run main.go data.mp4) > ./time/out.txt 2>&1
echo DONE
kill $!
time=`cat ./time/out.txt`
echo "$size,$isAttack,$time" >> ./time/time.txt1
echo
printf %s "(size,time) = "
printf %s "($size Mbytes, $time sec)"
echo


echo "Removing file"
rm data.mp4
rm ./time/out.txt
echo DONE
echo
unset TIMEFORMAT
echo -e '\033[32m ALL PROCESS DONE \033[m '
