if id hana >/dev/null 2>&1; then
	pkill -KILL -u hana 2>/dev/null
	userdel -r hana 2>/dev/null
fi
groupdel qa 2>/dev/null
rm -rf /var/tmp/lou-build.log /srv/lou-reports
true
