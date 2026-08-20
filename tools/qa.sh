#!/system/bin/bash
# qa.sh — QA otonom: latar belakang (JVM) + persiapan E2E one-shot.
set -uo pipefail
BD=/sdcard/projects/.build
mkdir -p "$BD"
case "${1:-}" in
  bg)   nohup bash /sdcard/projects/tools/gradle-build.sh start testDebugUnitTest > "$BD/qa-jvm.log" 2>&1 &
        echo "QA_JVM_STARTED: poll gradle-build.sh / qa-jvm.log; HP bebas dipakai" ;;
  fast) adb shell settings put global window_animation_scale 0
        adb shell settings put global transition_animation_scale 0
        adb shell settings put global animator_duration_scale 0
        echo ANIMATIONS_OFF ;;
  slow) adb shell settings put global window_animation_scale 1
        adb shell settings put global transition_animation_scale 1
        adb shell settings put global animator_duration_scale 1
        echo ANIMATIONS_ON ;;
  idle) adb shell dumpsys power 2>/dev/null | grep -iE 'mWakefulness|display power' | head -2 ;;
  *) echo "usage: qa.sh {bg|fast|slow|idle}" ;;
esac
