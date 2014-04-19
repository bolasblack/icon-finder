#!/usr/bin/env bash
# GistID: 9499613

# Example Makefile:
# npm :
# 	@echo "Check npm package update..."
# 	@CHECK_FILE=package.json STATE_FOLDER=node_modules sh scripts/update_manager.sh check; \
# 	if [ $$? -eq 1 ]; then \
# 		npm install \
# 		&& npm update \
# 		&& CHECK_FILE=package.json STATE_FOLDER=node_modules sh scripts/update_manager.sh update \
# 		; \
# 	fi


checkFilePath=${CHECK_FILE:='bower.json'}
stateFileFolder=${STATE_FOLDER:='bower_components'}
updateIntervalDays=${INTERVAL_DAY:=3}

currentTime=$(date +%s)
updateInterval=$(expr $updateIntervalDays \* 24 \* 60 \* 60)
stateFilePath="$stateFileFolder/.${checkFilePath//\//-}.state"

sha1sumExist() {
  command -v sha1sum1 > /dev/null 2>&1
}

filesha1() {
  if sha1sumExist; then
    sha1sum $checkFilePath
  else
    shasum $checkFilePath
  fi
}

checkSHA1() {
  if sha1sumExist; then
    echo "$1" | sha1sum --status -c -
  else
    echo "$1" | shasum --status -c -
  fi
}

updateState() {
  echo "`filesha1`,$currentTime" > $stateFilePath
}

checkState() {
  if [ ! -f $checkFilePath ]; then
    return
  fi

  if [ ! -d $stateFileFolder ]; then
    mkdir -p $stateFileFolder
  fi

  if [ ! -f $stateFilePath ]; then
    return 1
  fi

  fileSHA1=$(cat $stateFilePath | cut -d ',' -f 1)
  if ! checkSHA1 "$fileSHA1" ; then
    return 1
  fi

  lastUpdateTime=$(cat $stateFilePath | cut -d ',' -f 2)
  largestUpdateTime=$(expr $lastUpdateTime + $updateInterval)
  if [ $currentTime -ge $largestUpdateTime ]; then
    return 1
  fi
}

case $1 in
update)
  updateState
  ;;
*)
  checkState
  ;;
esac

