#!/bin/bash
# file: wittyPi.sh
#
# This application allows you to configure your Witty Pi
#

# check if sudo is used
if [ "$(id -u)" != 0 ]; then
  echo 'Sorry, you need to run this script with sudo'
  exit 1
fi

echo '================================================================================'
echo '|                                                                              |'
echo '|   Witty Pi - Realtime Clock + Power Management for Raspberry A+, B+ and 2    |'
echo '|                                                                              |'
echo '|                   < Version 1.50 >     by UUGear s.r.o.                      |'
echo '|                                                                              |'
echo '================================================================================'

# utilities
. utilities.sh

# interactive actions
set_auto_startup()
{
  local startup_time=$(get_local_date_time "$(get_startup_time)")
  local size=${#startup_time}
  if [ $size == '3' ]; then
    echo "  Auto startup time is not set yet.";
  else
    echo "  Auto startup time is currently set to \"$startup_time\"";
  fi
  read -p "  When do you want your Raspberry Pi to auto startup? (dd HH:MM:SS, ?? as wildcard) " when
  if [[ $when =~ ^[0-3\?][0-9\?][[:space:]][0-2\?][0-9\?]:[0-5\?][0-9\?]:[0-5\?][0-9\?]$ ]]; then
    IFS=' ' read -r date timestr <<< "$when"
    IFS=':' read -r hour minute second <<< "$timestr"
    wildcard='??'
    if [ $date != $wildcard ] && ([ $((10#$date>31)) == '1' ] || [ $((10#$date<1)) == '1' ]); then
      echo "  Day value should be 01~31."
    elif [ $hour != $wildcard ] && [ $((10#$hour>23)) == '1' ]; then
      echo "  Hour value should be 00~23."
    else
      local updated='0'
      if [ $hour == '??' ] && [ $date != '??' ]; then
        date='??'
        updated='1'
      fi
      if [ $minute == '??' ] && ([ $hour != '??' ] || [ $date != '??' ]); then
        hour='??'
        date='??'
        updated='1'
      fi
      if [ $second == '??' ]; then
        second='00'
        updated='1'
      fi
      if [ $updated == '1' ]; then
        when="$date $hour:$minute:$second"
        echo "  ...not supported pattern, but I can do \"$when\" for you..."
      fi
      echo "  Seting startup time to \"$when\""
      when=$(get_utc_date_time $date $hour $minute $second)
      IFS=' ' read -r date timestr <<< "$when"
      IFS=':' read -r hour minute second <<< "$timestr"
      set_startup_time $date $hour $minute $second
      echo "  Done :-)"
    fi
  else
    echo "  Sorry I don't recognize your input :-("
  fi
}

set_auto_shutdown()
{
  local off_time=$(get_local_date_time "$(get_shutdown_time)")
  local size=${#off_time}
  if [ $size == '3' ]; then
    echo  "  Auto shutdown time is not set yet."
  else
    echo -e "  Auto shutdown time is currently set to \"$off_time\b\b\b\"  ";
  fi
  read -p "  When do you want your Raspberry Pi to auto shutdown? (dd HH:MM, ?? as wildcard) " when
  if [[ $when =~ ^[0-3\?][0-9\?][[:space:]][0-2\?][0-9\?]:[0-5\?][0-9\?]$ ]]; then
    IFS=' ' read -r date timestr <<< "$when"
    IFS=':' read -r hour minute <<< "$timestr"
    wildcard='??'
    if [ $date != $wildcard ] && ([ $((10#$date>31)) == '1' ] || [ $((10#$date<1)) == '1' ]); then
      echo "  Day value should be 01~31."
    elif [ $hour != $wildcard ] && [ $((10#$hour>23)) == '1' ]; then
      echo "  Hour value should be 00~23."
    else
      local updated='0'
      if [ $hour == '??' ] && [ $date != '??' ]; then
        date='??'
        updated='1'
      fi
      if [ $minute == '??' ] && ([ $hour != '??' ] || [ $date != '??' ]); then
        hour='??'
        date='??'
        updated='1'
      fi
      if [ $updated == '1' ]; then
        when="$date $hour:$minute"
        echo "  ...not supported pattern, but I can do \"$when\" for you..."
      fi
      echo "  Seting shutdown time to \"$when\""
      when=$(get_utc_date_time $date $hour $minute '00')
      IFS=' ' read -r date timestr <<< "$when"
      IFS=':' read -r hour minute second <<< "$timestr"
      set_shutdown_time $date $hour $minute
      echo "  Done :-)"
    fi
  else
    echo "  Sorry I don't recognize your input :-("
  fi
}

# output system time
systime=">>> Your system time is: "
systime+="$(date +'%a %d %b %Y %H:%M:%S %Z')"
echo "$systime"

# output RTC time
rtctime=">>> Your RTC time is:    "
rtctime+="$(get_rtc_time)"
echo "$rtctime"

# ask user for action
echo "Now you can:"
echo "  1. Write system time to RTC"
echo "  2. Write RTC time to system"
echo "  3. Set time for auto startup"
echo "  4. Set time for auto shutdown"
echo "  5. Exit"
while true; do
    read -p "What do you want to do? (1~5) " action
    case $action in
        [1]* ) system_to_rtc;;
        [2]* ) rtc_to_system;;
        [3]* ) set_auto_startup;;
        [4]* ) set_auto_shutdown;;
        [5]* ) exit;;
        * ) echo "Please choose from 1 to 5";;
    esac
done
