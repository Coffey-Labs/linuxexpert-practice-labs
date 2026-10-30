grep -ls '/opt/test/lib' /etc/ld.so.conf.d/*.conf 2>/dev/null | xargs -r rm -f
rm -rf /opt/test
ldconfig
true
