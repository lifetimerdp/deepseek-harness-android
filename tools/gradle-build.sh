#!/system/bin/bash
# gradle-build.sh — peta build otonom (latar) untuk agen.
#   start <gradle args...>  mulai build latar, kembali seketika
#   status                  status + 5 baris log, kembali seketika
#   log [N]                 N baris terakhir log (default 50)
set -uo pipefail
BD=/sdcard/projects/.build
mkdir -p "$BD"
LOG=$BD/build.log
PIDF=$BD/build.pid
cmd="${1:-}"
[ "$#" -gt 0 ] && shift
case "$cmd" in
  start)
    if [ -f "$PIDF" ] && kill -0 "$(cat "$PIDF")" 2>/dev/null; then
      echo "BUILD_ALREADY_RUNNING pid=$(cat "$PIDF")"; exit 0
    fi
    PW=$(pwd)
    : > "$LOG"
    nohup proot-distro login ubuntu -- bash -c '
      export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-arm64
      export ANDROID_HOME=/opt/android-sdk
      export ANDROID_SDK_ROOT=/opt/android-sdk
      export PATH="$JAVA_HOME/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:/opt/gradle-8.13/bin:$PATH"
      cd "$1" && shift && exec gradle "$@"
    ' _ "$PW" "$@" > "$LOG" 2>&1 &
    echo $! > "$PIDF"
    echo "BUILD_STARTED pid=$(cat "$PIDF") log=$LOG"
    ;;
  status)
    if [ -f "$PIDF" ] && kill -0 "$(cat "$PIDF")" 2>/dev/null; then
      echo "STATUS=RUNNING pid=$(cat "$PIDF")"
    elif grep -q "BUILD SUCCESSFUL" "$LOG" 2>/dev/null; then
      echo "STATUS=SUCCESS"
    elif grep -q "BUILD FAILED" "$LOG" 2>/dev/null; then
      echo "STATUS=FAILED"
    elif [ -s "$LOG" ]; then
      echo "STATUS=CRASHED"
    else
      echo "STATUS=IDLE"
    fi
    tail -5 "$LOG" 2>/dev/null
    ;;
  log)
    tail -"${1:-50}" "$LOG" 2>/dev/null
    ;;
  *)
    echo "usage: gradle-build.sh {start <args>|status|log [N]}"
    ;;
esac
