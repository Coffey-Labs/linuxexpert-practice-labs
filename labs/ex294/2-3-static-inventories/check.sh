# ans CMD: run CMD as greg in his project directory.
ans() { timeout 120 runuser -l greg -c "cd ~/ansible && $*" </dev/null; }
# inv FILE PLUGIN: FILE as JSON, read only by that inventory plugin.
inv() { ans "ANSIBLE_INVENTORY_ENABLED=$2 ansible-inventory -i $1 --list --export"; }
# tree: the JSON on stdin has node1 in dev, node2 in test, node3 in prod
# and prod in webservers.
tree() {
	python3 -c 'import json, sys
d = json.load(sys.stdin)
h = lambda g: d.get(g, {}).get("hosts", [])
sys.exit(not ("node1" in h("dev") and "node2" in h("test") and "node3" in h("prod")
              and "prod" in d.get("webservers", {}).get("children", [])))'
}
I=/home/greg/ansible/inventory Y=/home/greg/ansible/inventory.yml
OUT=$LAB_STATE/check.out

task 1 "INI inventory: dev, test, prod, and webservers containing prod"
need "$I exists" '[ -f "$I" ]'
need "$I is an INI inventory" 'inv inventory ini >"$OUT" && grep -q . "$OUT"'
need "node1 is in dev, node2 in test, node3 in prod, and prod in webservers" 'tree <"$OUT"'
need "ansible webservers --list-hosts lists node3" 'ans ansible webservers --list-hosts | grep -qx " *node3"'

task 2 "The same inventory in YAML, with a variable on dev"
need "$Y exists" '[ -f "$Y" ]'
need "$Y is a YAML inventory" 'inv inventory.yml yaml >"$OUT" && grep -q . "$OUT"'
need "inventory.yml has node1 in dev, node2 in test, node3 in prod, and prod in webservers" 'tree <"$OUT"'
need "inventory.yml sets a variable on the dev group" 'python3 -c "import json, sys; sys.exit(not json.load(open(sys.argv[1])).get(\"dev\", {}).get(\"vars\"))" "$OUT"'
need "node1 gets dev's variables" 'ans ansible-inventory -i inventory.yml --host node1 >"$OUT.host" && python3 -c "import json, sys
v = json.load(open(sys.argv[1]))[\"dev\"][\"vars\"]; h = json.load(open(sys.argv[2]))
sys.exit(not all(h.get(k) == x for k, x in v.items()))" "$OUT" "$OUT.host"'

task 3 "control in the inventory, run locally"
need "the inventory has the host control" 'ans ansible-inventory --host control'
need "control has ansible_connection local" 'ans ansible-inventory --host control | python3 -c "import json, sys; sys.exit(json.load(sys.stdin).get(\"ansible_connection\") != \"local\")"'
need "ansible control -a hostname prints $(hostname)" 'ans ansible control -o -a hostname | grep -Fq "(stdout) $(hostname)"'
rm -f "$OUT" "$OUT.host"
