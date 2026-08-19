#!/system/bin/bash
# gradle-proot.sh <args> — jalankan Gradle di proot ubuntu (toolchain Android lengkap).
set -uo pipefail
PW=$(pwd)
exec proot-distro login ubuntu -- bash -c '
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-arm64
export ANDROID_HOME=/opt/android-sdk
export ANDROID_SDK_ROOT=/opt/android-sdk
export PATH="$JAVA_HOME/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:/opt/gradle-8.13/bin:$PATH"
cd "$1" && shift && exec gradle "$@"
' _ "$PW" "$@"
