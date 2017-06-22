#!/bin/bash
# Script to show basic info from linux machine
# Copyright (C) 2016 Augusto Morais <aflavio at gmail.com>
# Adapted from xero
# Permission to copy and modify is granted under the MIT license
# Last revised 10/11/2016


# draw progress bar
draw()
{
  #█▓▒░ other bars

  FULL=▓
  EMPTY=░

  perc=$1
  size=$2
  inc=$(( perc * size / 100 ))
  out=
  if [ -z $3 ]
  then
    color="36"
  else
    color="$3"
  fi
  for v in `seq 0 $(( size - 1 ))`; do
    test "$v" -le "$inc"   \
    && out="${out}\e[1;${color}m${FULL}" \
    || out="${out}\e[0;${color}m${EMPTY}"
  done
  printf $out
}


user='Augusto Morais <aflavio at gmail.com>'
host=`hostname`
battery=/sys/class/power_supply/BAT0
distro=`lsb_release -d | awk 'f=$1; $1=""; {print $0}' |  tail -n 1 | tail -c +2`
kernel=`uname -r`
uptime=`uptime -p | awk '{data=substr($0,4,40);printf (data)}'`


# Distros (Arch/Debian/Ubuntu)
if [[ $distro =~ .*Arch.* ]]; then
    pkgs=`pacman -Qq | wc -l`
else
    pkgs=`dpkg --get-selections | grep -v deinstall|  wc -l`
fi

# greets
printf " \e[0m  Welcome to \e[34m$host\n \e[0m \tConfigured by: \e[34m$user\n"
printf " \e[0m\n"

# environment
printf " \e[1;33m      distro \e[0m$distro\n"
printf " \e[1;33m      kernel \e[0m$kernel\n"
printf " \e[1;33m    packages \e[0m$pkgs\n"
printf " \e[1;33m      uptime \e[0m$uptime\n"
printf " \e[0m\n"

# cpu
cpu=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage}')
c_lvl=`printf "%.0f" $cpu`
printf "   \e[0;36m%-10s \e[1;36m%-5s %-25s \n" " cpu" "$c_lvl%" `draw $c_lvl 15`

# ram
ram=`free | awk '/Mem:/ {print int($3/$2 * 100.0)}'`
printf "   \e[0;36m%-10s \e[1;36m%-5s %-25s \n" " ram" "$ram%" `draw $ram 15`

# swap
swap=`free | awk '/Swap:/ {print int($3/$2 * 100.0)}'`
printf "   \e[0;36m%-10s \e[1;36m%-5s %-25s \n" " swap" "$swap%" `draw $swap 15`

# temperature
#temp=`sensors | awk '/Core\ 0/ {gsub(/\+/,"",$3); gsub(/\..+/,"",$3)    ; print $3}'`
#case 1 in
#  $(($temp <= 50)))
#    color='34'
#    ;;
#  $(($temp >= 75)))
#    color='31'
#    ;;
#  *)
#    color='36'
#    ;;
#esac
#printf "   \e[0;${color}m%-10s \e[1;${color}m%-5s %-25s \n\n" "temp" "$temp°c " `draw $temp 15 $color`

# storage
IFS=$'\n'
printf "\n  \e[1;36m%-5s \n" " Storage"
for s in $(df -h | awk '/sda/ {printf ("%5s %6s\n", $5, $6)}'); do
   #$partition = `awk $s '{print $1} | head -c -2'`
   #echo $partition
   usage=$(echo $s | awk '{print $1}' | sed 's/%//g' | tail -n 1)
   device=$(echo $s | awk '{print $2}')
   printf "  \e[0;36m%-11s \e[1;36m%-5s %-25s \n" " $device" "$usage%" `draw $usage 15`
done
printf "\n\e[0m"


