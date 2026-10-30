command -v nft >/dev/null || pkg_install nftables
nft list table inet lab >/dev/null 2>&1 && nft delete table inet lab
rm -f /tmp/lab.nft
peer_up
true
