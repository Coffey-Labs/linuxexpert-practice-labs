vgf() { vgs --noheadings --units m --nosuffix -o "$2" "$1" 2>/dev/null | tr -d ' '; }
lvf() { lvs --noheadings --units m --nosuffix -o "$2" "$1" 2>/dev/null | tr -d ' '; }
pv_vg() { pvs --noheadings -o vg_name "$1" 2>/dev/null | tr -d ' '; }

task 1 "vgdata with 8 MiB extents; lvdata of 50 extents"
need "volume group vgdata exists" vgs vgdata
need "/dev/loop40p1 is a physical volume in vgdata" '[ "$(pv_vg /dev/loop40p1)" = vgdata ]'
need "vgdata's extents are 8 MiB" '[ "$(vgf vgdata vg_extent_size)" = 8.00 ]'
need "logical volume vgdata/lvdata exists" lvs vgdata/lvdata
need "lvdata is 50 extents (400 MiB)" '[ "$(lvf vgdata/lvdata lv_size)" = 400.00 ]'

task 2 "/dev/loop40p2 in vgdata; lvrest uses all the space left"
need "/dev/loop40p2 is a physical volume in vgdata" '[ "$(pv_vg /dev/loop40p2)" = vgdata ]'
need "vgdata has 2 physical volumes" '[ "$(vgf vgdata pv_count)" = 2 ]'
need "logical volume vgdata/lvrest exists" lvs vgdata/lvrest
need "vgdata has no free space left" '[ "$(vgf vgdata vg_free_count)" = 0 ]'

task 3 "vgold, its logical volumes and physical volumes removed"
need "lvone and lvtwo are gone" '! lvs vgold/lvone && ! lvs vgold/lvtwo'
need "volume group vgold is gone" '! vgs vgold'
need "/dev/loop41p1 and /dev/loop41p2 are no longer physical volumes" '! pvs /dev/loop41p1 && ! pvs /dev/loop41p2'
need "lsblk -f shows no LVM2_member on them" '[ -b /dev/loop41p1 ] && [ -b /dev/loop41p2 ] && ! blkid -p /dev/loop41p1 /dev/loop41p2 | grep -q LVM2_member'
