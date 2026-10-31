UD=/root/cloud/user-data AI=/root/cloud/autoinstall.yaml
valid() { cloud-init schema -c "$1" 2>&1 | grep -q "Valid schema"; }
# py FILE CODE: run CODE with the YAML of FILE as d; true if it prints ok.
py() {
	python3 -I - "$1" "$2" <<'X' 2>/dev/null | grep -qx ok
import subprocess, sys, yaml
d = yaml.safe_load(open(sys.argv[1]))
def key_ok(k):
    r = subprocess.run(["ssh-keygen", "-l", "-f", "-"], input=k.encode(), capture_output=True)
    return r.returncode == 0
def lst(v):
    return v if isinstance(v, list) else ([] if v is None else [v])
def user(name):
    for u in lst(d.get("users")):
        if isinstance(u, dict) and u.get("name") == name:
            return u
    return {}
def groups(u):
    g = u.get("groups", [])
    return [x.strip() for x in (g.split(",") if isinstance(g, str) else lst(g))]
if eval(sys.argv[2]):
    print("ok")
X
}
motd_ok='any(isinstance(f, dict) and f.get("path") == "/etc/motd" and "built by cloud-init" in str(f.get("content", "")) for f in lst(d.get("write_files"))) or any("built by cloud-init" in str(c) and "/etc/motd" in str(c) for c in lst(d.get("runcmd")) + lst(d.get("bootcmd")))'

task 1 "user-data: user deploy with a key and sudo, htop, /etc/motd"
need "/root/cloud/user-data exists" test -f $UD
need "it starts with #cloud-config" '[ "$(head -n1 $UD | tr -d "\r ")" = "#cloud-config" ]'
need "cloud-init schema -c says Valid schema" valid $UD
need "it creates user deploy" 'py $UD "bool(user(\"deploy\"))"'
need "deploy gets an SSH public key" 'py $UD "any(key_ok(k) for k in lst(user(\"deploy\").get(\"ssh_authorized_keys\")))"'
need "deploy gets sudo rights" 'py $UD "\"ALL\" in str(user(\"deploy\").get(\"sudo\", \"\")) or \"sudo\" in groups(user(\"deploy\"))"'
need "it installs htop" 'py $UD "\"htop\" in [str(p) for p in lst(d.get(\"packages\"))]"'
need "it writes built by cloud-init to /etc/motd" 'py $UD "$motd_ok"'

task 2 "autoinstall: db1, dbadmin with a \$6\$ hash, SSH, LVM, postgresql"
need "/root/cloud/autoinstall.yaml exists" test -f $AI
need "it starts with #cloud-config" '[ "$(head -n1 $AI | tr -d "\r ")" = "#cloud-config" ]'
need "cloud-init schema -c accepts it" valid $AI
need "everything is under autoinstall:, with version: 1" 'py $AI "list(d) == [\"autoinstall\"] and d[\"autoinstall\"].get(\"version\") == 1"'
need "the hostname is db1 and the user dbadmin" 'py $AI "d[\"autoinstall\"][\"identity\"][\"hostname\"] == \"db1\" and d[\"autoinstall\"][\"identity\"][\"username\"] == \"dbadmin\""'
need "the password is a \$6\$ hash" 'py $AI "str(d[\"autoinstall\"][\"identity\"][\"password\"]).startswith(\"\$6\$\") and len(str(d[\"autoinstall\"][\"identity\"][\"password\"]).split(\"\$\")) == 4"'
need "SSH is installed, with password logins off" 'py $AI "d[\"autoinstall\"][\"ssh\"][\"install-server\"] is True and d[\"autoinstall\"][\"ssh\"][\"allow-pw\"] is False"'
need "the storage layout is lvm" 'py $AI "d[\"autoinstall\"][\"storage\"][\"layout\"][\"name\"] == \"lvm\""'
need "it installs postgresql" 'py $AI "\"postgresql\" in [str(p) for p in lst(d[\"autoinstall\"].get(\"packages\"))]"'
