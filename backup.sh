#!/bin/bash

printRedText() {
  printf '\e[31m%s\e[0m' "$1"
}

printYellowText() {
  printf '\e[33m%s\e[0m' "$1"
}

printGreenText() {
  printf '\e[32m%s\e[0m' "$1"
}

requireDirectoryExists() {
  if ! [[ -d "$1" ]]; then
    printf "\n"
    printRedText "  ERROR: Directory \"$1\" does not exist!"
    printf "\n\n"
    exit 1
  fi
}

requireDirectoriesDoNotMatch() {
  if [[ $1 == "$2" ]]; then
    printf "\n"
    printRedText "  ERROR: You must not specify the same directory twice!"
    printf "\n\n"
    exit 1
  fi
}

requireNotEmpty() {
  if [[ $1 == "" ]]; then
    printf "\n"
    printRedText "  ERROR: $2"
    printf "\n\n"
    exit 1
  fi
}

startupBanner="
+==========================================================================+
|                                      _                _                  |
|  _ __ ___ _   _ _ __   ___          | |__   __ _  ___| | ___   _ _ __    |
| | '__/ __| | | | '_ \ / __|  _____  | '_ \ / _\` |/ __| |/ / | | | '_ \\   |
| | |  \__ \ |_| | | | | (__  |_____| | |_) | (_| | (__|   <| |_| | |_) |  |
| |_|  |___/\\__, |_| |_|\\___|         |_.__/ \\__,_|\\___|_|\\_\\\\__,_| .__/   |
|           |___/                                                 |_|      |
|   by: Daniel Pallinger                                                   |
+==========================================================================+"

printf "%s\n\n" "$startupBanner"

read -p "  Source: " sourceDirectory
requireDirectoryExists "$sourceDirectory"
sourceDirectory="$(realpath "$sourceDirectory")/"

read -p "  Destination: " destinationDirectory
requireDirectoryExists "$destinationDirectory"
destinationDirectory="$(realpath "$destinationDirectory")/"

read -p "  Logfile path (without file extension): " logfilePath
requireNotEmpty "$logfilePath" "You must specify where the logfile should be stored!"
logfilePath="$logfilePath-$(date +"%Y-%m-%d").log"

printf "\n"
read -n 1 -p "  Delete files from destination that do not exist in source? (y/n): " deleteOption
printf "\n"
read -n 1 -p "  Perform dry-run? (y/n): " dryRunOption

command="sudo rsync -aiuv --no-links --no-owner --no-group"

if [ "$deleteOption" == "y" ]; then
  command+=" --delete"
fi

if [ "$dryRunOption" == "y" ]; then
  command+=" --dry-run"
fi

command+=" $sourceDirectory $destinationDirectory"
displayedCommand="$command $sourceDirectory $destinationDirectory | tee $logfilePath"

printf "\n\n  Command:\n      %s\n" "$displayedCommand"
printf "\n\t\tSource: "
printGreenText "$sourceDirectory"
printf " ---> Destination: "
printRedText "$destinationDirectory"

printf "\n\n"
read -n 1 -p "  Run the displayed command? (y/n): " startBackup

if [ "$startBackup" == "y" ]; then
  printf "\n"
  printf "  Do you really want to run the command? (y/n): "
  read -n 1 -p "" startBackup

  if [ "$startBackup" == "y" ]; then
    printf "\n\n"
    $command | tee "$logfilePath"
  fi
fi
