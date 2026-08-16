#!/system/bin/bash
export DEBIAN_FRONTEND=noninteractive
AO='-o Dpkg::Options::=--force-confold -o Dpkg::Options::=--force-confdef'
P=/sdcard/projects
T=$P/tools

echo "[1] storage permission"
termux-setup-storage
i=0
until [ -w /sdcard ]; do
i=$((i+1))
if [ $i -gt 60 ]; then
echo "Grant the Android storage permission, then re-run."
exit 1
fi
sleep 2
done
mkdir -p $T
echo "[2] termux packages (slow, normal)"
apt update -y || exit 1
apt -y $AO upgrade || exit 1
apt -y $AO install proot-distro \
openssh curl openjdk-17 \
aapt dx apksigner || exit 1
mkdir -p ~/.ssh
ssh-keygen -A
sshd 2>/dev/null
echo "[3] API key"
if [ ! -f $P/.dsh-env ]; then
echo -n "API key (DeepSeek or OpenAI-compatible): "
read -r K </dev/tty
echo -n "Base URL (Enter = DeepSeek official): "
read -r B </dev/tty
echo -n "Model (Enter = deepseek-v4-flash): "
read -r M </dev/tty
{
echo "export DEEPSEEK_API_KEY=$K"
echo "export OPENAI_API_KEY=$K"
[ -n "$B" ] && echo "export DEEPSEEK_BASE_URL=$B"
[ -n "$B" ] && echo "export OPENAI_BASE_URL=$B"
[ -n "$M" ] && echo "export DEEPSEEK_DEFAULT_MODEL=$M"
} > $P/.dsh-env
chmod 600 $P/.dsh-env
fi
echo "[4] ubuntu (~100MB, normal)"
n=0
until proot-distro list 2>/dev/null | grep -qw ubuntu; do
n=$((n+1))
if [ $n -gt 3 ]; then
echo "Ubuntu install failed after 3 attempts."
exit 1
fi
echo "Attempt $n/3..."
proot-distro install ubuntu
if ! proot-distro list 2>/dev/null | grep -qw ubuntu; then
echo "Attempt $n failed, cleaning up..."
proot-distro remove ubuntu 2>/dev/null
sleep 10
fi
done
echo "[5] proot setup"
cat > $T/proot-setup.sh << 'PS'
export DEBIAN_FRONTEND=noninteractive
AO='-o Dpkg::Options::=--force-confold -o Dpkg::Options::=--force-confdef'
apt update -y
apt -y $AO install curl gnupg \
ca-certificates \
openssh-client
if ! command -v node >/dev/null; then
curl -fsSL \
https://deb.nodesource.com/setup_22.x \
| bash -
apt -y $AO install nodejs
fi
node -v
if ! command -v dsh >/dev/null; then
npm i -g --no-fund --no-audit \
@deepseek-ai/dsh
fi
mkdir -p /root/.ssh /root/.dsh
if [ ! -f /root/.ssh/id_ed25519 ]; then
ssh-keygen -t ed25519 -N "" \
-f /root/.ssh/id_ed25519 -q
fi
echo "[]" > /root/.dsh/cordis.patch.yml
printf "permission:\n  defaultPreset: danger-full-access\n" > /root/.dsh/settings.yaml
echo OK-PROOT
PS
proot-distro login ubuntu -- \
bash $T/proot-setup.sh || exit 1
proot-distro login ubuntu -- bash $T/fixkey.sh
proot-distro login ubuntu -- bash $T/fixpty.sh
proot-distro login ubuntu -- cat /root/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys
sort -u ~/.ssh/authorized_keys \
-o ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
echo "[6] project assets"
cp -f $P/AGENTS.md $P/CLAUDE.md
chmod +x $T/build-apk.sh
if [ ! -f $T/android.jar ]; then
J=https://raw.githubusercontent.com
J=$J/Sable/android-platforms
J=$J/master/android-34/android.jar
curl -fsSL $J -o $T/android.jar
fi
cat > $T/start-dsh.sh << 'LD'
#!/system/bin/bash
sshd 2>/dev/null
if curl -s -o /dev/null --max-time 2 http://127.0.0.1:3080; then
echo "dsh already running on port 3080"
exit 0
fi
proot-distro login ubuntu -- \
bash -c \
"source /sdcard/projects/.dsh-env \
2>/dev/null; cd /sdcard/projects \
&& exec dsh web"
LD
chmod +x $T/start-dsh.sh
echo "== DONE: open http://127.0.0.1:3080 =="
if ! command -v zipalign >/dev/null; then
cat > $PREFIX/bin/zipalign << 'ZS'
#!/system/bin/sh
while [ $# -gt 2 ]; do shift; done
cp -f "$1" "$2"
ZS
chmod +x $PREFIX/bin/zipalign
fi
