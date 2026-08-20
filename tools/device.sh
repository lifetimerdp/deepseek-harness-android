#!/system/bin/bash
# device.sh — peta debug perangkat nyata (adb nirkabel loopback).
set -uo pipefail
BD=/sdcard/projects/.build
mkdir -p "$BD"
ADDRF=$BD/adb.addr
PKG=com.nasi.app
APK=/sdcard/projects/nasi/app/build/outputs/apk/debug/app-debug.apk
ready(){ adb devices 2>/dev/null | awk '{print $2}' | grep -qx device; }
case "${1:-}" in
  pair)   echo "$3" | adb pair "127.0.0.1:$2" ;;
  connect)
    ready && { echo DEVICE=READY; exit 0; }
    A="${2:-$(cat $ADDRF 2>/dev/null)}"
    if [ -n "$A" ]; then timeout 5 adb connect "$A" >/dev/null 2>&1
      ready && { echo "$A" > $ADDRF; echo DEVICE=READY; exit 0; }; fi
    S=$(timeout 8 adb mdns services 2>/dev/null | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}:[0-9]+' | head -1)
    if [ -n "$S" ]; then timeout 5 adb connect "$S" >/dev/null 2>&1
      ready && { echo "$S" > $ADDRF; echo DEVICE=READY; exit 0; }; fi
    for P in $(python3 - << 'PY'
known={3080}
out=[]
for f in ("/proc/net/tcp","/proc/net/tcp6"):
    try:
        for ln in open(f).readlines()[1:]:
            p=ln.split()
            if len(p)>3 and p[3]=="0A":
                out.append(int(p[1].rsplit(":",1)[1],16))
    except OSError: pass
print(" ".join(str(x) for x in sorted(set(out)-known)))
PY
) ; do
      timeout 2 adb connect "127.0.0.1:$P" >/dev/null 2>&1
      ready && { echo "127.0.0.1:$P" > $ADDRF; echo DEVICE=READY; exit 0; }
    done
    echo "PERLU_PORT: pastikan toggle Wireless debugging ON (satu tap bila OFF setelah reboot); kirim IP:port — TANPA pairing ulang"; exit 1 ;;
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
  *) echo "usage: device.sh {pair PORT KODE|connect [IP:PORT]|install|launch|ui|tap X Y|text S|key K|log [N]|shot}" ;;
esac
