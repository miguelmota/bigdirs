#!/bin/bash

#================================================================
# HEADER
#================================================================
#% SYNOPSIS
#+    bigdirs [flags] {path}
#%
#% DESCRIPTION
#%    Scan for big directories (>1GB).
#%
#% EXAMPLES
#%    bigdirs ~/
#%    bigdirs -e ~/
#%    bigdirs -v ~/
#%    bigdirs -v -e ~/
#%
#================================================================
#- IMPLEMENTATION
#-    version         bigdirs (https://github.com/miguelmota/bigdirs) 0.0.1
#-    author          Miguel Mota https://miguelmota.com
#-    license         MIT License
#-
#================================================================
# END_OF_HEADER
#================================================================

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

SCAN_PATH=""
VERBOSE="false"
EXHAUSTIVE="false"

# flags
while getopts 'ev' flag; do
  case "${flag}" in
    e) EXHAUSTIVE='true' ;;
    v) VERBOSE='true' ;;
    *) echo "Unexpected option ${flag}"; exit 1 ;;
  esac
done

for arg in "$@"
do
  # if arg doesn't contain leading dash,
  # then it's not a flag
  if ! [[ "$arg" =~ ^-.*$ ]]; then
    SCAN_PATH="${arg}"
  fi
done

# If no path is passed, show error with example
if [ "$SCAN_PATH" == "" ]; then
  printf "%s\n\n%s" "Path required." "Example: bigdirs ~/"
  exit 1
fi

# results array
resultsSize=()
resultsPath=()

function scan() {
  # pathname argument
  local DIR=$(realpath $1)

  if ! [ "$EXHAUSTIVE" == "true" ]; then
    # turn off expansion
    set -f
  fi

  # if doesn't end with an asterisk and is directory
  if ! [[ $DIR =~ ^.*\*$ ]] && [[ -d $DIR ]]; then

    # show current scan directory if verbose
    if [ "$VERBOSE" == "true" ]; then
      printf "Scanning %s\n" "$DIR"
    fi

    # perform directory size scan
    while read LINE; do
      SIZE="$(echo "$LINE" | grep -oE '.*G')"
      CUR_PATH="$(echo "$LINE" | grep -oE '\s.*' | sed -e 's/^[[:space:]]*//')"

      # add to results array
      resultsSize+=("${SIZE}")
      resultsPath+=("${CUR_PATH}")

      # show current scan directory result if verbose
      if [ "$VERBOSE" == "true" ]; then
        printf "$bold$yellow%s %s$normal $yellow%s$nc\n" "Found" "$SIZE" "$CUR_PATH"
      fi

      # start a new scan on new path
      if [[ -d $CUR_PATH ]]; then
        scan_top "$CUR_PATH"
      fi

    # need to pass command like this
    # to modify results var inside while loop
    done < <(/usr/bin/du -sh -- "$DIR" | /usr/bin/sort -n | grep 'G\s')

    if ! [ "$EXHAUSTIVE" == "true" ]; then
      # turn on expansion
      set +f
    fi
  fi
}

function scan_top() {
  # realpath is to remove last slash
  local CUR_PATH=$(realpath "$1")

  # list directories
  for DIR in "$CUR_PATH"/*; do
    # scan directory
    scan "$DIR"
  done
}

# start message
printf "$yellow%s$nc\n" "Running..."

# start scan
scan_top "$SCAN_PATH"

# show a table with results
printf "\n%s\n" "----------------------------"
printf "%s\n" "BIG DIRS"
printf "%s\n" "----------------------------"
printf "Size\tPath\n"

# iterate over results array
i=0
for line in "${resultsPath[@]}"; do
  printf "$green$bold%s$normal\t$green%s$nc\n" "${resultsSize[$i]}" "${resultsPath[$i]}"
  (( i++ ))
done

# end of table
printf "\n%s\n" "----------------------------"

# shoe complete message
printf "\n$green%s$nc\n" "Done."