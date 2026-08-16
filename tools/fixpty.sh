export DEBIAN_FRONTEND=noninteractive
apt update -y >/dev/null 2>&1
apt -y install build-essential \
python3 make g++ >/dev/null 2>&1
D=/usr/lib/node_modules/@deepseek-ai/dsh
N=$D/node_modules/node-pty
cd $N || exit 1
npx node-gyp rebuild
ls -la build/Release/pty.node
echo PTY-FIX-DONE
