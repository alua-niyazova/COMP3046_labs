// Output cup: Ø35 bearing journals, Ø50 cable drum with a groove, 2 mm cable
// slot through the centre, X-ribbed interior and an 8-hole tool flange on top.

include <wrist_params.scad>

orient_for_print = true;   // flange up, flat bottom on the bed

cup_journal_r = b6807[0] / 2 - 0.12;
cup_drum_r    = 24.97;
cup_flange_holes = 8;
cup_hole_d    = 2.48;
cup_hole_pcd  = 20.08;
cup_hole_rot  = -12.4;
cup_rib_t     = 2;
cup_rib_rot   = 56;
cup_slot_rot  = 11.2;

module cup() {
    jr = cup_journal_r;
    difference() {
        rotate_extrude() polygon([
            [0, -16.5], [jr - 0.5, -16.5], [jr, -16], [jr, -9.5],
            [17.87, -9.5], [17.87, -9.08], [cup_drum_r, -3.13],
            [cup_drum_r, 3.13], [17.87, 9.08], [17.87, 9.5],
            [jr, 9.5], [jr, 16], [jr - 0.5, 16.5], [0, 16.5]]);
        // cable groove
        rotate_extrude() translate([26.5, 0]) circle(r = groove_r);
        // four pockets under the flange, separated by an X of ribs
        difference() {
            translate([0, 0, -16.5 - eps]) cylinder(r = 14.97, h = 26 + eps);
            for (a = [cup_rib_rot, cup_rib_rot + 90])
                rotate([0, 0, a]) cube([40, cup_rib_t, 60], center = true);
        }
        // cable anchor slot straight through the drum
        rotate([0, 0, cup_slot_rot]) cube([60, 2, 1.86], center = true);
        // tool flange holes
        for (i = [0 : cup_flange_holes - 1])
            rotate([0, 0, cup_hole_rot + i * 360 / cup_flange_holes])
                translate([cup_hole_pcd / 2, 0, 9]) cylinder(d = cup_hole_d, h = 10, $fn = 24);
    }
}

if (orient_for_print) translate([0, 0, 16.5]) cup();
else cup();
