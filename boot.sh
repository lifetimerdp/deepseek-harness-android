#!/system/bin/bash
command -v curl >/dev/null 2>&1 || pkg in -y curl
cd /sdcard || { echo "Jalankan: termux-setup-storage, lalu ulangi."; exit 1; }
curl -fsSL https://github.com/lifetimrdp/deepseek-harness-android/archive/refs/heads/main.tar.gz -o $HOME/repo.tar.gz || exit 1
rm -rf $HOME/repo-extract
mkdir -p $HOME/repo-extract
tar xzf $HOME/repo.tar.gz -C $HOME/repo-extract --strip-components=1 || exit 1
mkdir -p /sdcard/projects/tools
cp -f $HOME/repo-extract/AGENTS.md /sdcard/projects/
cp -f $HOME/repo-extract/tools/*.sh /sdcard/projects/tools/
chmod +x /sdcard/projects/tools/*.sh
bash /sdcard/projects/tools/pasang.sh && bash /sdcard/projects/tools/start-dsh.sh
