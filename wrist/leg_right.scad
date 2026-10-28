// Right-hand leg (x > 0). Ø54 disc with a 6807 pocket, 30 mm wide arm with a
// 45° chamfer, channel that clamps the 20x20 rod with 2x2 M3 bolts, cable
// idler slot in the disc and a cable groove down the outside face.
// leg_left.scad mirrors this file.

include <wrist_params.scad>

orient_for_print = true;   // outer face on the bed, bearing pocket up

leg_disc_r   = 27;
leg_w        = 30;
leg_bottom   = -60;
leg_wall     = 5.6;          // channel side walls, measured from the channel
leg_pocket_r = b6807[1] / 2 + 0.05 + fit;
leg_lip_r    = 22.55;
leg_boss_r   = 12;
leg_slot     = [8, 24];      // idler slot width (y) and height (z)
bolt_d       = 3.15;
bolt_head_d  = 6.2;
bolt_y       = 6;            // set to 0 to hit the centre slot of a slotted 2020 extrusion
bolt_z       = [-42, -56];
bolt_seat_x  = 14;           // where the counterbore starts

// clearance swept by the yoke (x, r), revolved about X
leg_arch = [[0, 37.2], [4, 36.75], [7.04, 35.9], [10.78, 35.06], [14, 33.7],
            [17.21, 31.77], [20.78, 29], [leg_x[0], 29]];

module leg() {
    x0 = leg_x[0]; x1 = leg_x[1];
    xin = rod_gap / 2 - leg_wall;
    difference() {
        union() {
            difference() {
                union() {
                    // disc with a 2 mm chamfer on the outer edge
                    revolve_x([[x0, 0], [x0, leg_disc_r], [x1 - 2, leg_disc_r], [x1, leg_disc_r - 2], [x1, 0]]);
                    // arm
                    along_y() linear_extrude(leg_w, center = true) mirror([0, 1, 0])
                        polygon([[xin, leg_bottom], [14, leg_bottom],
                                 [x1, leg_bottom + 30], [x1, 0], [xin, 0]]);
                }
                revolve_x(concat([[-1, 0], [-1, 37.2]], leg_arch, [[x0, 0]]));
                // bearing pocket and retaining lip
                revolve_x([[x0 - eps, 0], [x0 - eps, leg_pocket_r], [40, leg_pocket_r],
                           [40, leg_lip_r], [41, leg_lip_r], [41, 0]]);
            }
            // boss carrying the idler pin
            translate([36, 0, 0]) along_x() cylinder(r = leg_boss_r, h = x1 - 36);
        }
        // idler slot
        translate([36 - eps, -leg_slot[0] / 2, -leg_slot[1] / 2]) cube([x1 - 36 + 1, leg_slot[0], leg_slot[1]]);
        // idler pin
        translate([leg_idler[0], 0, leg_idler[1]]) rotate([90, 0, 0])
            cylinder(d = pin_d, h = 2 * leg_disc_r + 2, center = true, $fn = 24);
        // cable groove on the outside face
        along_y() linear_extrude(3, center = true) mirror([0, 1, 0])
            polygon([[36.92, -37.07], [45.4, -4.6], [50, -4.6], [50, -37.07]]);
        // rod channel
        translate([-1, -rod_gap / 2, leg_bottom - 1]) cube([rod_gap / 2 + 1, rod_gap, 60]);
        // M3 bolts into the rod, with head counterbores
        for (y = [-bolt_y, bolt_y], z = bolt_z) translate([0, y, z]) {
            translate([rod_gap / 2 - 1, 0, 0]) along_x() cylinder(d = bolt_d, h = bolt_seat_x - rod_gap / 2 + 1 + eps, $fn = 24);
            translate([bolt_seat_x, 0, 0]) along_x() cylinder(d = bolt_head_d, h = 40, $fn = 32);
        }
    }
}

if (orient_for_print) rotate([0, 90, 0]) translate([-leg_x[1], 0, 0]) leg();
else leg();
