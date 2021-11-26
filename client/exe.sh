#!/bin/bash

#======================================================================
# functions
#======================================================================
function usage() {
  echo "Usage: ./exe.sh <isAttack> <times> <startsize> <endsize> <increment>"
  return
}

#======================================================================
# main
#======================================================================

if [ $# -ne 5 ]; then
  echo "ERROR: sepcify the args"
  usage
  exit 1
fi

if   [ $1 -eq 0 ]; then
  isattack="normal"
elif [ $1 -eq 1 ]; then
  isattack="onAttack"
else
  echo "isAttack have to be 0(normal) or 1(onAttack)"
  usage
  exit 2
fi

if [ $3 -gt $4 ]; then 
  echo "ERROR: startsize must be bigger than endsize"
  usage
  exit 3
fi

times=$2
size=$3
maxsize=$4
inc=$5


while [ $size -lt $maxsize ]; do
  echo "File size: $size Mbytes"
  echo
  echo "Making file ..."
  dd if=/dev/zero of="data.mp4" bs=1M count=$size > /dev/null 2>&1 &
  echo "DONE"
  
  t=0
  while [ $t -lt $times ]; do

# start dumping
expect <<EOF
set timeout 10
spawn ssh hisa@192.168.15.30 -p 12150
expect ">> "
send "echo 'hogehoge' | nohup sudo -S tcpdump src host 192.168.15.32 and port 50051 or dst host 192.168.15.32 and port 50051 -w ~/logs/${size}MB_${t}_${isattack}.pcap > /dev/null 2>&1 & \n"
expect ">> "
send "exit\n"
EOF

# start sending
    TIMEFORMAT='%3R'
    echo 
    echo Sending...
    (time ./client data.mp4) > ./time/out.txt 2>&1
    echo DONE
    kill $!
    time=`cat ./time/out.txt`
    echo "$size,$t,$isattack" >> ./time/time.txt
    echo
    printf %s "(size,time) = "
    printf %s "($size Mbytes, $time sec)"
    echo
    
# stop dumping
expect <<EOF
set timeout 10
spawn ssh hisa@192.168.15.30 -p 12150
expect ">> "
send "echo hogehoge | sudo -S kill $\(ps aux | egrep '^tcpdump' | sed -e 's/ \[ \]*/ /g'| cut -d' ' -f2\) \n"
expect ">> "
send "sleep 2\n"
expect ">> "
send "exit\n"
EOF

#send "echo hogehoge | sudo -S kill \$\(ps aux | egrep '^tcpdump' | sed -e 's/ \[ \]*/ /g'| cut -d' ' -f2\) \n"

#post-processing

    t=$(expr $t + 1)

    printf %s "DONE: (size,times) = "
    printf %s "($size Mbytes, $t times)"
  done

  echo "Removing file"
  rm data.mp4
  rm ./time/out.txt
  echo DONE
  echo
  echo
  size=$(expr $size + $inc)
done

unset TIMEFORMAT
echo
echo -e '\033[32m ALL PROCESS DONE \033[m '

