K=/usr/share/keyrings/ubuntu-archive-keyring.gpg
U=/root/usb

task 1 "SHA256SUMS downloaded and its signature good"
need "/root/usb/SHA256SUMS and SHA256SUMS.gpg exist" '[ -s $U/SHA256SUMS ] && [ -s $U/SHA256SUMS.gpg ]'
need "SHA256SUMS lists the 24.04 images" 'grep -q "ubuntu-24\.04.*\.iso" $U/SHA256SUMS'
need "gpgv says the signature is good" 'gpgv --keyring $K $U/SHA256SUMS.gpg $U/SHA256SUMS'

task 2 "A copy with one character changed fails the check"
need "/root/usb/SHA256SUMS.copy exists" '[ -f $U/SHA256SUMS.copy ]'
need "it differs from SHA256SUMS in exactly one character" '[ "$(stat -c %s $U/SHA256SUMS.copy)" = "$(stat -c %s $U/SHA256SUMS)" ] && [ "$(cmp -l $U/SHA256SUMS $U/SHA256SUMS.copy | wc -l)" = 1 ]'
need "gpgv reports a bad signature for it" 'gpgv --keyring $K $U/SHA256SUMS.gpg $U/SHA256SUMS.copy 2>&1 | grep -q "BAD signature"'

task 3 "An ISO labeled TEST written to /dev/loop40"
need "xorriso is installed" 'command -v xorriso'
need "/dev/loop40 holds an ISO 9660 filesystem" '[ "$(blkid -p -s TYPE -o value /dev/loop40)" = iso9660 ]'
need "its label is TEST" '[ "$(blkid -p -s LABEL -o value /dev/loop40)" = TEST ]'
