#!/bin/zsh
# .zlogin — MOTD banner displayed on terminal login
# BitWise-0x (R0b) | https://github.com/BitWise-0x
# Compatible with bash (sourced from .bash_profile)

# Define terminal colors — purple/violet gradient palette
_reset="\e[0m"
_bold="\e[1m"
_white="\e[39m"
_dim="\e[38;5;243m"
_ice="\e[38;5;189m"
_lav="\e[38;5;183m"
_periwinkle="\e[38;5;147m"
_lilac="\e[38;5;141m"
_violet="\e[38;5;135m"
_purple="\e[38;5;98m"
_deep="\e[38;5;56m"
_indigo="\e[38;5;54m"

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
hardwareData=$( /usr/sbin/system_profiler SPHardwareDataType 2>/dev/null )
batteryData=$( /usr/sbin/system_profiler SPPowerDataType 2>/dev/null )
modelName=$( /usr/bin/grep 'Model Name' <<< "$hardwareData" | /usr/bin/awk -F': ' '{print $2}' | /usr/bin/xargs )
modelIdentifier=$( /usr/bin/grep 'Model Identifier' <<< "$hardwareData" | /usr/bin/awk -F': ' '{print $2}' | /usr/bin/xargs )
serialNumber=$( /usr/bin/grep 'Serial Number' <<< "$hardwareData" | /usr/bin/awk -F': ' '{print $2}' | /usr/bin/xargs )
memory=$( /usr/bin/grep 'Memory' <<< "$hardwareData" | /usr/bin/awk -F': ' '{print $2}' | /usr/bin/xargs )
processorSpeed=$( /usr/bin/grep 'Chip' <<< "$hardwareData" | /usr/bin/awk -F': ' '{print $2}' | /usr/bin/xargs )
[ -z "$processorSpeed" ] && processorSpeed=$( /usr/bin/grep 'Processor Speed' <<< "$hardwareData" | /usr/bin/awk -F': ' '{print $2}' | /usr/bin/xargs )
activationLock=$( /usr/bin/grep 'Activation Lock' <<< "$hardwareData" | /usr/bin/awk -F': ' '{print $2}' | /usr/bin/xargs )

# Banner
echo
echo
echo -e "${_ice}                        'c.           ${_white} ${_bold}$( /usr/bin/id -un )${_reset}${_dim}@${_bold}${_white}$( hostname -s )${_reset}"
echo -e "${_ice}                     ,xNMM.           ${_dim} ---------------------------------"
echo -e "${_lav}                   .0MMMMo            ${_periwinkle} OS ${_white} $( /usr/bin/sw_vers -productName ) $( /usr/bin/sw_vers -productVersion )"
echo -e "${_lav}                   0MMM0,             ${_periwinkle} Host ${_white} $( hostname )"
echo -e "${_periwinkle}         .;loddo:' loolloddol;.       ${_periwinkle} Model ${_white} $modelName"
echo -e "${_periwinkle}       cKMMMMMMMMMMNWMMMMMMMMMM0:     ${_periwinkle} ID ${_white} $modelIdentifier"
echo -e "${_lilac}     .KMMMMMMMMMMMMMMMMMMMMMMMMWd.    ${_periwinkle} SN ${_white} $serialNumber"
echo -e "${_lilac}     ;XMMMMMMMMMMMMMMMMMMMMMMMX.      ${_periwinkle} Memory ${_white} $memory"
echo -e "${_violet}     ;MMMMMMMMMMMMMMMMMMMMMMMM:       ${_periwinkle} Chip ${_white} $processorSpeed"
echo -e "${_violet}     :MMMMMMMMMMMMMMMMMMMMMMMM:       ${_periwinkle} Disk ${_white} $( /usr/bin/fdesetup status )"
echo -e "${_purple}     .MMMMMMMMMMMMMMMMMMMMMMMMX.      ${_periwinkle} Lock ${_white} $activationLock"
echo -e "${_purple}      kMMMMMMMMMMMMMMMMMMMMMMMMWd.    ${_periwinkle} Uptime ${_white} $( /usr/bin/uptime 2> /dev/null | /usr/bin/sed 's/.*up //' | /usr/bin/sed 's/,[^,]*user.*//' | /usr/bin/xargs )"
echo -e "${_deep}      .XMMMMMMMMMMMMMMMMMMMMMMMMMMk   ${_periwinkle} Battery ${_white} $( /usr/bin/awk '/Cycle Count/{ print $3 }' <<< "$batteryData") cycles"
echo -e "${_deep}       .XMMMMMMMMMMMMMMMMMMMMMMMMK.   ${_periwinkle} Shell ${_white} $SHELL"
echo -e "${_indigo}         kMMMMMMMMMMMMMMMMMMMMMMd.    ${_white}"
echo -e "${_indigo}          ;KMMMMMMMWXXWMMMMMMMMk.     ${_lav} $( /bin/date +"Today is %A, %B %d, %Y" )"
echo -e "${_indigo}            .cooc,.    .,coo:.        ${_periwinkle} On this day: ${_white}$event"
echo -e "${_reset}"
echo