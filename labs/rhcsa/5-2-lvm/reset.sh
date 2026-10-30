# The volume groups go with the spare disks; deactivate them first.
for vg in vgdata vgold; do
	vgchange -an "$vg" >/dev/null 2>&1
done
true
