# The OpenSSH version, as 9.6 or 9.9.
V=$(ssh -V 2>&1 | grep -oE 'OpenSSH_[0-9]+\.[0-9]+' | cut -d_ -f2)
changelog() {
	if is_rhel; then rpm -q --changelog openssh-server
	elif [ -f /usr/share/doc/openssh-server/changelog.Debian.gz ]; then zcat /usr/share/doc/openssh-server/changelog.Debian.gz
	else apt-get changelog openssh-server 2>/dev/null; fi
}

task 1 "The SSH product and version nmap found"
need "/root/lab-answers/1 names OpenSSH and its version" 'answer 1 | grep -q openssh && answer 1 | grep -qF "$V"'

task 2 "A CVE fixed in openssh-server"
need "/root/lab-answers/2 has a CVE ID" 'grep -Eqi "CVE-[0-9]{4}-[0-9]{4,}" /root/lab-answers/2'
need "the CVE is in the package's changelog" 'c=$(grep -Eoi "CVE-[0-9]{4}-[0-9]{4,}" /root/lab-answers/2 | head -1); changelog | grep -qiw "$c"'

task 3 "A CIS scan report in /root/cis.html" rhel
need "/root/cis.html is an OpenSCAP report" 'grep -q "OpenSCAP" /root/cis.html'
need "it's from a CIS profile" 'grep -Eq "content_profile_cis" /root/cis.html'
