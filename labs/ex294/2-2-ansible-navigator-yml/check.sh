nodes_wait 60 || true
# ans CMD: run CMD as greg in his project directory.
ans() { timeout 300 runuser -l greg -c "cd ~/ansible && $*" </dev/null; }
# eff KEY...: a value from navigator's effective settings, under
# ansible-navigator:, e.g. eff execution-environment image.
eff() {
	python3 -c 'import sys, yaml
v = yaml.safe_load(open(sys.argv[1]))["ansible-navigator"]
for k in sys.argv[2:]: v = v[k]
print(v)' "$OUT.eff" "$@"
}
OUT=$LAB_STATE/check.out
ans ansible-navigator settings --effective >"$OUT.eff" 2>/dev/null
ans ansible-navigator settings --effective --sources -m stdout >"$OUT.src" 2>/dev/null
src() { grep -Fqx "ansible-navigator.$1: Settings file" "$OUT.src"; }

task 1 "ansible-navigator.yml: lab-ee:2.16, never pull, stdout, no artifacts"
need "/home/greg/ansible/ansible-navigator.yml exists" 'ls /home/greg/ansible/ansible-navigator.y*ml /home/greg/ansible/ansible-navigator.json 2>/dev/null | grep -q .'
need "the image is localhost/lab-ee:2.16, from the settings file" '[ "$(eff execution-environment image)" = localhost/lab-ee:2.16 ] && src execution-environment.image'
need "the pull policy is never, from the settings file" '[ "$(eff execution-environment pull policy)" = never ] && src execution-environment.pull.policy'
need "the mode is stdout, from the settings file" '[ "$(eff mode)" = stdout ] && grep -Fqx "ansible-navigator.mode: Settings file" <(ans ansible-navigator settings --effective --sources)'
need "playbook artifacts are off, from the settings file" '[ "$(eff playbook-artifact enable)" = False ] && src playbook-artifact.enable'
need "ansible-navigator run site.yml works on node1 and node2" 'ans ansible-navigator run site.yml >"$OUT"; grep -Eq "^node1 +: ok=[1-9].* failed=0" "$OUT" && grep -Eq "^node2 +: ok=[1-9].* failed=0" "$OUT"'

task 2 "The error a pull policy of always gives for a local-only image"
need "/root/lab-answers/2 has navigator's error" 'grep -qi "execution environment pull failed" /root/lab-answers/2'

task 3 "The module that fails without the execution environment"
need "/root/lab-answers/3 names the module, in full" '[ "$(answer 3)" = community.general.ini_file ]'
rm -f "$OUT" "$OUT.eff" "$OUT.src"
