task 1 "EPEL and CRB enabled, htop from EPEL" rhel
need "epel-release is installed" 'pkg_installed epel-release'
need "the crb repository is enabled" 'dnf repolist --enabled 2>/dev/null | grep -q "^crb "'
need "htop is installed from EPEL" 'dnf list --installed htop 2>/dev/null | grep -q epel'

task 2 "editor chosen with update-alternatives" debian
need "the editor alternative is set by hand (manual mode)" 'update-alternatives --query editor | grep -qx "Status: manual"'

task 3 "~/venv with requests"
need "~/venv is a virtual environment" '[ -x /root/venv/bin/python3 ] && [ -f /root/venv/pyvenv.cfg ]'
need "requests is installed in it" '/root/venv/bin/python3 -c "import requests" && /root/venv/bin/pip show requests'

task 4 "hi built from source with make"
need "~/src/hi.c and ~/src/Makefile exist" '[ -f /root/src/hi.c ] && [ -f /root/src/Makefile ]'
need "the Makefile has hi and install targets" 'grep -q "^hi:" /root/src/Makefile && grep -q "^install:" /root/src/Makefile'
need "~/src/hi prints built" '[ "$(/root/src/hi)" = built ]'
need "make install puts it in /usr/local/bin" 'make -C /root/src -n install | grep -q /usr/local/bin'
