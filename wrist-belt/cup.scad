// Output cup: bearing journals, HTD 5M drum for the roll belt, X-ribbed
// interior and an 8-hole tool flange on top.

include <wrist_params.scad>

orient_for_print = true;   // flange up, flat bottom on the bed

cup_journal_r = b6709[0] / 2 - 0.12;
cup_shoulder_r = b6709[0] / 2 + 0.37;   // on the inner race
drum_fl_t     = 1;
drum_fl_over  = 1;          // small flanges: the yoke idlers sit close
cup_pocket_r  = min(cup_journal_r, htd_root(drum_teeth)) - 3;
cup_flange_holes = 8;
cup_hole_d    = 2.48;
cup_hole_pcd  = 20.08;
cup_hole_rot  = -12.4;
cup_rib_t     = 2;
cup_rib_rot   = 56;

module cup() {
    jr = cup_journal_r;
    fr = htd_ro(drum_teeth) + drum_fl_over;
    bh = roll_band_h / 2;
    rr = htd_root(drum_teeth);
    sr = cup_shoulder_r;
    z0 = cup_bearing_z - b6709[2] / 2;   // bearing inner faces
    z1 = cup_bearing_z + b6709[2] / 2;   // cup ends
    difference() {
        union() {
            rotate_extrude() polygon([
                [0, -z1], [jr - 0.5, -z1], [jr, -z1 + 0.5], [jr, -z0],
                [sr, -z0], [sr, -z0 + 0.42], [fr, -bh - drum_fl_t], [fr, -bh],
                [rr, -bh], [rr, bh], [fr, bh], [fr, bh + drum_fl_t],
                [sr, z0 - 0.42], [sr, z0], [jr, z0], [jr, z1 - 0.5], [jr - 0.5, z1], [0, z1]]);
            htd_teeth(drum_teeth, roll_band_h, center = true);
        }
        // four pockets under the flange, separated by an X of ribs
        difference() {
            translate([0, 0, -z1 - eps]) cylinder(r = cup_pocket_r, h = z1 + z0 + eps);
            for (a = [cup_rib_rot, cup_rib_rot + 90])
                rotate([0, 0, a]) cube([40, cup_rib_t, 60], center = true);
        }
        // tool flange holes
        for (i = [0 : cup_flange_holes - 1])
            rotate([0, 0, cup_hole_rot + i * 360 / cup_flange_holes])
                translate([cup_hole_pcd / 2, 0, z0 - 0.5]) cylinder(d = cup_hole_d, h = 10, $fn = 24);
    }
}

if (orient_for_print) translate([0, 0, cup_bearing_z + b6709[2] / 2]) cup();
else cup();
