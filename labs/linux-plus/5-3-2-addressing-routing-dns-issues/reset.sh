systemctl disable --now --quiet le-lab-peer-net.service 2>/dev/null
rm -f /etc/systemd/system/le-lab-peer-net.service /usr/local/lib/le-lab/peer-net.sh
rmdir /usr/local/lib/le-lab 2>/dev/null
systemctl daemon-reload
ip link del le-far 2>/dev/null
rm -f /etc/NetworkManager/conf.d/91-le-lab-far.conf
systemctl reload NetworkManager 2>/dev/null
rm -f /etc/netns/lepeer/network
rmdir /etc/netns/lepeer /etc/netns 2>/dev/null
sed -i '/^192\.0\.2\.99[[:space:]].*www\.kernel\.org/d' /etc/hosts
true
