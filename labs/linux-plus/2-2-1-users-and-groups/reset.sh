userdel -r labuser 2>/dev/null
userdel -r labsvc 2>/dev/null
groupdel labgroup 2>/dev/null
rm -rf /etc/skel/bin
true
