#!bin/sh

echo 'hogehoge' | sudo -S tcpdump src host 192.168.15.32 and port 50051 or dst host 192.168.15.32 and port 50051 -w ~/logs/$i.pcap > /dev/null 2>&1 &
