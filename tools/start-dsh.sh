#!/system/bin/bash
sshd 2>/dev/null
URL=http://127.0.0.1:3080
LOCK=/sdcard/projects/.dsh-start.lock
up() { curl -s -o /dev/null --max-time 2 "$URL"; }
if up; then
echo "dsh already running on port 3080"
exit 0
fi
if [ -d "$LOCK" ]; then
age=$(( $(date +%s) - $(stat -c %Y "$LOCK") ))
if [ "$age" -gt 300 ]; then
echo "Removing stale lock (older than 5 minutes)."
rm -rf "$LOCK"
else
echo "Another start is in progress; waiting up to 60s..."
i=0
while [ $i -lt 30 ]; do
sleep 2
if up; then
echo "dsh already running on port 3080"
exit 0
fi
i=$((i+1))
done
echo "No server appeared; removing stale lock and continuing."
rm -rf "$LOCK"
fi
fi
mkdir "$LOCK" 2>/dev/null || { echo "Another start just began; exiting."; exit 1; }
trap 'rm -rf "$LOCK"' EXIT
proot-distro login ubuntu -- \
bash -c \
"source /sdcard/projects/.dsh-env \
2>/dev/null; cd /sdcard/projects \
&& exec dsh web"
