for p in cups cups-daemon cups-pdf printer-driver-cups-pdf cups-bsd cups-client cups-ipptool cups-ipp-utils epel-release; do
	pkg_installed "$p" && echo "$p" >>"$LAB_STATE/had-pkgs"
done
pkg_installed cups && refuse "CUPS is installed already; task 1 installs it. Remove it first."
user_add alice
pkg_install cups-ipptool/cups-ipp-utils
touch "$LAB_STATE/stamp"
true
