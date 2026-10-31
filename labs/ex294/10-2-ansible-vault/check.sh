nodes_wait 60 || true
# ans CMD: run CMD as greg in his project directory.
ans() { setsid -w timeout -k 5 180 runuser -l greg -c "cd ~/ansible && $*" </dev/null; }
A=/home/greg/ansible
OUT=$LAB_STATE/check.out
# view [PASSWORD]: secret.yml decrypted with vault-pass.txt, or with PASSWORD.
view() {
	if [ $# -eq 0 ]; then ans ansible-vault view secret.yml --vault-password-file vault-pass.txt
	else ans "ansible-vault view secret.yml --vault-password-file <(echo '$1')"; fi
}
# The vault's user_password, if the password file opens it.
PW=$(view 2>/dev/null | python3 -c 'import sys, yaml
d = yaml.safe_load(sys.stdin)
print(d.get("user_password", "") if isinstance(d, dict) else "")' 2>/dev/null)
# pw_ok: vaultuser's password on node1 is $PW.
pw_ok() {
	local h; h=$(in_node node1 getent shadow vaultuser | cut -d: -f2)
	[ -n "$PW" ] && [ -n "$h" ] && PW=$PW H=$h python3 -W ignore -c 'import crypt, os, sys
sys.exit(crypt.crypt(os.environ["PW"], os.environ["H"]) != os.environ["H"])'
}
# A terminal for --ask-vault-pass: askpass FILE CMD... answers the prompt
# once with the password in FILE and exits with CMD's status (99 if no
# prompt came).
cat >"$LAB_STATE/askpass.py" <<'P'
import os, pty, select, sys, time
pw, cmd = open(sys.argv[1]).read().strip(), sys.argv[2:]
pid, fd = pty.fork()
if pid == 0:
    os.execvp(cmd[0], cmd)
buf, sent, end = b"", False, time.time() + 60
while time.time() < end:
    if not select.select([fd], [], [], 1)[0]:
        continue
    try:
        d = os.read(fd, 4096)
    except OSError:
        break
    if not d:
        break
    buf += d
    if not sent and b"assword:" in buf:
        os.write(fd, pw.encode() + b"\n")
        sent = True
sys.stdout.write(buf.decode(errors="replace"))
if time.time() >= end:
    os.kill(pid, 9)
_, st = os.waitpid(pid, 0)
sys.exit(os.waitstatus_to_exitcode(st) if sent else 99)
P
chmod 644 "$LAB_STATE/askpass.py"
navcfg() {
	python3 -c 'import sys, yaml
n = (yaml.safe_load(open(sys.argv[1])) or {}).get("ansible-navigator", {})
ok = n.get("mode") == "stdout" and (n.get("playbook-artifact") or {}).get("enable") in (False, "false")
sys.exit(0 if ok else 1)' $A/ansible-navigator.yml
}

task 1 "An encrypted secret.yml, and vaultuser on node1 with its password"
need "$A/vault-pass.txt exists with mode 600" "[ \"\$(stat -c %a $A/vault-pass.txt)\" = 600 ]"
need "$A/secret.yml is encrypted (starts with \$ANSIBLE_VAULT)" "head -1 $A/secret.yml | grep -q '^\\\$ANSIBLE_VAULT'"
need "vault-pass.txt opens secret.yml, which sets user_password" '[ -n "$PW" ]'
need "$A/vault.yml exists and uses secret.yml" "grep -q secret.yml $A/vault.yml"
need "vaultuser exists on node1" 'in_node node1 id vaultuser'
need "vaultuser's password on node1 is user_password from the vault" pw_ok

task 2 "A new vault password, in vault-pass.txt"
need "vault-pass.txt opens secret.yml" '[ -n "$PW" ]'
need "vault-pass.txt doesn't hold RedhatVault any more" "! grep -qx RedhatVault $A/vault-pass.txt"
need "RedhatVault no longer opens secret.yml" '! view RedhatVault'

task 3 "vault.yml runs in ansible-navigator, with the password file and the prompt"
need "ansible-navigator.yml sets mode: stdout and playbook artifacts off" navcfg
need "ansible-navigator run vault.yml --vault-password-file vault-pass.txt works" 'ans ansible-navigator run vault.yml --vault-password-file vault-pass.txt >"$OUT" && grep -q "PLAY RECAP" "$OUT"'
need "ansible-navigator run vault.yml --ask-vault-pass asks and works" "[ -n \"\$PW\" ] && ans python3 -I $LAB_STATE/askpass.py vault-pass.txt ansible-navigator run vault.yml --ask-vault-pass >\"\$OUT\" && grep -q 'PLAY RECAP' \"\$OUT\""
rm -f "$OUT"
