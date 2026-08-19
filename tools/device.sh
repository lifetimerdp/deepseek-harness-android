#!/system/bin/bash
# device.sh — peta debug perangkat nyata (adb nirkabel loopback). OPSIONAL.
set -uo pipefail
BD=/sdcard/projects/.build
mkdir -p "$BD"
ADDRF=$BD/adb.addr
PKG=com.nasi.app
APK=/sdcard/projects/nasi/app/build/outputs/apk/debug/app-debug.apk
case "${1:-}" in
  connect)
    adb get-state 2>/dev/null | grep -q device && { echo DEVICE=READY; exit 0; }
    if [ -n "${2:-}" ]; then echo "$2" > $ADDRF; A=$2; else A=$(cat $ADDRF 2>/dev/null); fi
    [ -z "$A" ] && { echo "PERLU_ALAMAT_SEKALI: minta '127.0.0.1:port' dari layar Wireless debugging"; exit 1; }
    adb connect "$A" && adb devices ;;
  install) adb install -r "$APK" ;;
  launch)  adb shell monkey -p "$PKG" -c android.intent.category.LAUNCHER 1 ;;
  ui)      adb shell uiautomator dump /sdcard/projects/.build/ui.xml >/dev/null 2>&1
           python3 - "$BD/ui.xml" << 'PY'
import xml.etree.ElementTree as ET,sys
for n in ET.parse(sys.argv[1]).getroot().iter('node'):
    a=n.attrib
    if a.get('text') or a.get('resource-id'):
        print(a.get('resource-id','')[:45],'|',a.get('text','')[:30],'|',a.get('bounds'))
PY
           ;;
  tap)  adb shell input tap "$2" "$3" ;;
  text) adb shell input text "$2" ;;
  key)  adb shell input keyevent "$2" ;;
  log)  P=$(adb shell pidof "$PKG" 2>/dev/null | tr -d '\r')
        if [ -n "$P" ]; then adb logcat -d --pid="$P" | tail -"${2:-100}"; else adb logcat -d *:E | tail -"${2:-100}"; fi ;;
  shot) adb shell screencap -p /sdcard/projects/.build/shot.png && echo SHOT=$BD/shot.png ;;
  *) echo "usage: device.sh {connect [IP:PORT]|install|launch|ui|tap X Y|text S|key K|log [N]|shot}" ;;
esac
