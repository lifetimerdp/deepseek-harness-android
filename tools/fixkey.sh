export DEBIAN_FRONTEND=noninteractive
command -v ssh-keygen || \
apt -y install openssh-client
mkdir -p /root/.ssh
if [ ! -f /root/.ssh/id_ed25519 ]; then
ssh-keygen -t ed25519 -N "" \
-f /root/.ssh/id_ed25519 -q
fi
echo KEY-PUB:
cat /root/.ssh/id_ed25519.pub
echo DSH:
command -v dsh
