nodes_wait 60 || true
OUT=$LAB_STATE/check.out
J=/home/greg/ansible/.devcontainer/devcontainer.json
# gp CMD: run podman CMD as greg.
gp() { timeout 120 runuser -l greg -c "podman $*" </dev/null; }
for n in $(nodes_names); do in_node "$n" cat /var/log/lab-runs.log 2>/dev/null; done >"$OUT.runs"

task 1 "A podman dev container for the project, with the image's Ansible"
need "$J exists" '[ -f "$J" ]'
need "devcontainer.json names an image" 'python3 -c "import json, re, sys
s = re.sub(r\"^\s*//.*$\", \"\", open(sys.argv[1]).read(), flags=re.M)
sys.exit(not json.loads(s).get(\"image\"))" "$J"'
C=$(gp ps -a -q --filter label=devcontainer.local_folder=/home/greg/ansible 2>/dev/null | head -1)
need "greg has a dev container for /home/greg/ansible" '[ -n "$C" ]'
[ -n "$C" ] && gp start "$C" >/dev/null 2>&1
need "ansible --version in the container finds /workspaces/ansible/ansible.cfg" 'gp exec -w /workspaces/ansible "$C" ansible --version | grep -qx "  config file = /workspaces/ansible/ansible.cfg"'

task 2 "site.yml reaches the nodes from inside the container"
need "a node logged a run of site.yml from /workspaces/ansible" 'grep -q " /workspaces/ansible ansible-core " "$OUT.runs"'

task 3 "devcontainer CLI: up, and site.yml with devcontainer exec"
need "greg can run devcontainer --version" 'timeout 60 runuser -l greg -c "devcontainer --version" </dev/null'
need "a node logged a run of site.yml from /workspaces/ansible outside VS Code" 'grep " /workspaces/ansible ansible-core " "$OUT.runs" | grep -q " from a shell$"'
rm -f "$OUT".*
