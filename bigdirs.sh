#!/bin/bash

nc='\033[0m'
red="\033[31m"
green='\033[32m'
yellow='\033[33m'
blue='\033[34m'
purple='\033[35m'
cyan='\033[36m'
white='\033[37m'
bold=$(tput bold)
normal=$(tput sgr0)

SCAN_PATH="$1"

if [ -z $1 ]; then
  SCAN_PATH="$HOME"
fi

function scan() {
  local DIR="$1"

  # turn off expansion
  set -f

  # if doesn't end with an asterisk
  if ! [[ $DIR =~ ^.*\*$ ]]; then

    printf "Scanning %s\n" "$DIR"

    # perform directory size scan
    /usr/bin/du -sh -- "$DIR" | /usr/bin/sort -n | grep 'G\s' | while read LINE; do
      SIZE="$(echo "$LINE" | grep -oE '.*G')"
      CUR_PATH="$(echo "$LINE" | grep -oE '\s.*' | sed -e 's/^[[:space:]]*//')"
      printf "$green$bold%s$normal $green%s$nc\n" "$SIZE" "$CUR_PATH"
      if [[ -d $CUR_PATH ]]; then
        scan_root "$CUR_PATH"
      fi
    done

    # turn on expansion
    set +f
  fi
}

function scan_root() {
  # realpath is to remove last slash
  local CUR_PATH=$(realpath "$1")

  printf "\n"

  # list directories
  for DIR in "$CUR_PATH"/*; do
    # scan directory
    scan "$DIR"
  done
}

# start message
printf "$yellow%s$nc\n" "Starting..."

# start scan
scan_root "$SCAN_PATH"

# complete
printf "\n$green%s$nc" "Done."