#!/bin/bash
#Hardware and System info by @texnotes
#will be run with root privileges

outfile="task4_1.out"

#Read information from target system
cpu_info=$(cat /proc/cpuinfo | grep 'model name'| awk '{print $0}'| cut -f 3- -d' ')
mem_info=$(cat /proc/meminfo | grep MemTotal | awk '{print $2" " $3}')
brd_info=$(dmidecode -s baseboard-manufacturer)
brd_name=$(dmidecode -s baseboard-product-name)
sys_serial=$(dmidecode -s system-serial-number)
distro=$(cat /etc/os-release | grep "PRETTY_NAME" | sed 's/PRETTY_NAME=//g' | sed 's/["]//g' )
kernel=$(uname -r)
inst_data=$(ls -lact --full-time /etc |awk 'END {print $6}')
uptime=$(uptime | awk -F'( |,|:)+' '{if ($7=="min") m=$6; else {if ($7~/^day/) {d=$6;h=$8;m=$9} else {h=$6;m=$7}}} {print d+0,"days,",h+0,"hours,",m+0,"minutes"}')
proc_run=$(ps -e | sed -e '1d' | wc -l)
usersess=$(who|wc -l)

#Testing for missing components
[ "$brd_info" == "" ] && brd_info="Unknown"
[ "$brd_name" == "" ] && brd_name="Unknown"
[ "$sys_serial" == "" ] && sys_serial="Unknown"

exec 1>$outfile
#Output structured data
echo "--- Hardware ---"
echo "CPU: $cpu_info"
echo "RAM: $mem_info"
echo "Motherboard: $brd_info $brd_name"
echo "System Serial Number: $sys_serial"
echo "--- System ---"
echo "OS Distribution: $distro"
echo "Kernel version: $kernel"
echo "Installation date: $inst_data"
echo "Hostname: $HOSTNAME"
echo "Uptime: $uptime"
echo "Processes running: $proc_run"
echo "Users logged in: $usersess"
echo "--- Network ---"

for iface in $(ifconfig | cut -d ' ' -f1| tr '\n' ' ')
do
  addr=$(ip -o -4 addr list $iface | awk '{print $4}')
  [ "$addr" == "" ] && addr="-"
  printf "$iface: $addr\n"
done

