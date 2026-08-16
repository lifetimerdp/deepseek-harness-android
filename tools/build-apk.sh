#!/bin/bash
# Pemakaian: bash build-apk.sh <folder-proyek> <nama-output>
set -e
PROJ="$1"; NAME="${2:-app}"
AJAR="$HOME/android-sdk/android.jar"
OUT="$PROJ/out"
rm -rf "$OUT"; mkdir -p "$OUT/gen" "$OUT/obj"

echo "[1/6] aapt: membuat R.java"
aapt package -f -m -J "$OUT/gen" -M "$PROJ/AndroidManifest.xml" -S "$PROJ/res" -I "$AJAR"

echo "[2/6] javac: kompilasi Java"
find "$OUT/gen" "$PROJ/src" -name "*.java" > "$OUT/sources.txt"
javac -nowarn --release 8 -classpath "$AJAR" -d "$OUT/obj" @"$OUT/sources.txt"

echo "[3/6] dx: membuat classes.dex"
dx --dex --output="$OUT/classes.dex" "$OUT/obj"

echo "[4/6] aapt: mengemas APK"
aapt package -f -M "$PROJ/AndroidManifest.xml" -S "$PROJ/res" -I "$AJAR" -F "$OUT/$NAME-unaligned.apk"
cd "$OUT" && aapt add -f "$NAME-unaligned.apk" classes.dex && cd -

echo "[5/6] zipalign (opsional)"
if command -v zipalign >/dev/null 2>&1; then
  zipalign -f 4 "$OUT/$NAME-unaligned.apk" "$OUT/$NAME-unsigned.apk"
else
  echo "  zipalign tidak ada - dilewati (APK tetap valid)"
  cp "$OUT/$NAME-unaligned.apk" "$OUT/$NAME-unsigned.apk"
fi

echo "[6/6] apksigner: tanda tangan"
apksigner sign --ks "$HOME/android-sdk/debug.keystore" \
  --ks-pass pass:android --key-pass pass:android \
  --out "$OUT/$NAME.apk" "$OUT/$NAME-unsigned.apk"

echo "SUKSES: $OUT/$NAME.apk"
