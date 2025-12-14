#!/bin/zsh

:<<ABOUT_THIS_SCRIPT
-----------------------------------------------------------------------

	Written by:William Smith
	Partner Program Manager
	Jamf
	bill@talkingmoose.net
	https://gist.github.com/talkingmoose/15f055885b51cc8cb0bc7aad021acead
	Originally posted: May 22
	

	Updated by: JackieTreehorn (R0b)
	https://github.com/BitWise-0x
	Updated: Oct 17, 2024
	Changes:
	- Standardized calendar location
	- Added additional FreeBSD calendars | pick random event from random calendar to display ("On this Day:")
	- Refactored logic, etc
	

	Inspired by Neofetch!
	https://github.com/dylanaraps/neofetch

	Purpose: Display useful computer information when logging in to a new
	Terminal window.

	Except where otherwise noted, this work is licensed under
	http://creativecommons.org/licenses/by/4.0/

	"Caps Lock: Preventing login since 1980."

	INSTRUCTIONS

	1) Using a Terminal text editor like Vim, Vi, Va Va Voom or a
	   GUI text editor like BBEdit on your Mac, create or edit
	   the .zlogin file at the root of your home directory.
	2) Paste this entire script into the editor and save. If you're
	   using Vim or Vi, good luck.
	3) The script should run every time a new Terminal window opens.
	
-----------------------------------------------------------------------
ABOUT_THIS_SCRIPT

# Define terminal colors
_white="\e[39m"
__blue="\e[38;5;4m"
_green="\e[38;5;120m"
orange="\e[38;5;172m"
purple="\e[38;5;90m"
___red="\e[38;5;196m"
yellow="\e[38;5;221m"

# Base dir for calendars
calendarDir="$HOME/local/share/calendar"
mkdir -p "$calendarDir"

# Calendars
calendarURLs=(
    "https://raw.githubusercontent.com/freebsd/calendar-data/main/calendar.computer"
    "https://raw.githubusercontent.com/freebsd/calendar-data/main/calendar.history"
    "https://raw.githubusercontent.com/freebsd/calendar-data/main/calendar.usholiday"
    # "https://raw.githubusercontent.com/freebsd/calendar-data/main/calendar.lotr"
)

# Download if not exists
for url in "${calendarURLs[@]}"; do
    calendarFile="$calendarDir/$(basename "$url")"
    if [[ ! -f "$calendarFile" ]]; then
        curl -o "$calendarFile" "$url" || echo "Failed to download $url"
    fi
done

# Collect cal events
onThisDay=""
for calendarFile in "$calendarDir"/*; do
    events=$( /usr/bin/calendar -f "$calendarFile" | /usr/bin/awk -F '\t' '{ print $2 }' )
    if [[ -n "$events" ]]; then
        onThisDay+="$events"$'\n'
    fi
done

# Pick random event
if [[ -z "$onThisDay" ]]; then
    event="🍺"
else
    # Trim trailing newlines and count events
    onThisDay=$(echo "$onThisDay" | sed '/^$/d')
    eventCount=$( echo "$onThisDay" | /usr/bin/wc -l | xargs )
    randomNumber=$(( $RANDOM % eventCount + 1 ))
    event=$( echo "$onThisDay" | /usr/bin/sed -n "${randomNumber}p" )
fi

# Pull hardware information
hardwareData=$( /usr/sbin/system_profiler SPHardwareDataType )
batteryData=$( /usr/sbin/system_profiler SPPowerDataType )
modelName=$( /usr/bin/grep 'Model Name' <<< "$hardwareData" | /usr/bin/xargs )
modelIdentifier=$( /usr/bin/grep 'Model Identifier' <<< "$hardwareData" | /usr/bin/xargs )
serialNumber=$( /usr/bin/grep 'Serial Number' <<< "$hardwareData" | /usr/bin/xargs )
memory=$( /usr/bin/grep 'Memory' <<< "$hardwareData" | /usr/bin/xargs )
processorSpeed=$( /usr/bin/grep 'Processor Speed' <<< "$hardwareData" | /usr/bin/xargs )

# Banner
echo
echo
echo -e "${_green}                        'c.           ${_white} Logged in as: $( /usr/bin/id -un )"
echo -e "${_green}                     ,xNMM.           ${_white} ---------------------------------"
echo -e "${_green}                   .0MMMMo            ${_white} Operating System: $( /usr/bin/sw_vers -productName ) $( /usr/bin/sw_vers -productVersion )"
echo -e "${_green}                   0MMM0,             ${_white} Computer Name: $( hostname )"
echo -e "${_green}         .;loddo:' loolloddol;.       ${_white} $modelName"
echo -e "${_green}       cKMMMMMMMMMMNWMMMMMMMMMM0:     ${_white} $modelIdentifier"
echo -e "${yellow}     .KMMMMMMMMMMMMMMMMMMMMMMMMWd.    ${_white} $serialNumber"
echo -e "${yellow}     ;XMMMMMMMMMMMMMMMMMMMMMMMX.      ${_white} $memory"
echo -e "${orange}     ;MMMMMMMMMMMMMMMMMMMMMMMM:       ${_white} $processorSpeed"
echo -e "${orange}     :MMMMMMMMMMMMMMMMMMMMMMMM:       ${_white} $( /usr/bin/fdesetup status )"
echo -e "${___red}     .MMMMMMMMMMMMMMMMMMMMMMMMX.      ${_white} $( /usr/bin/grep 'Activation Lock' <<< "$hardwareData" | /usr/bin/xargs )"
echo -e "${___red}      kMMMMMMMMMMMMMMMMMMMMMMMMWd.    ${_white} Uptime: $( /usr/bin/uptime 2> /dev/null | /usr/bin/awk -F '(up |, [0-9]+ users)' '{ print $2 }' )"
echo -e "${purple}      .XMMMMMMMMMMMMMMMMMMMMMMMMMMk   ${_white} Battery Cycle Count: $( /usr/bin/awk '/Cycle Count/{ print $3 }' <<< "$batteryData")"
echo -e "${purple}       .XMMMMMMMMMMMMMMMMMMMMMMMMK.   ${_white} Shell: $SHELL"
echo -e "${__blue}         kMMMMMMMMMMMMMMMMMMMMMMd.    ${_white}"
echo -e "${__blue}          ;KMMMMMMMWXXWMMMMMMMMk.     ${_white} $( /bin/date +"Today is %A, %B %d, %Y" )"
echo -e "${__blue}            .cooc,.    .,coo:.        ${_white} On this day: $event"
echo
echo