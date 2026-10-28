// Common leg body (right-hand, x > 0), used by leg_pitch.scad and leg_roll.scad.
// Disc with a 6709 pocket and a hole in the end wall, 30 mm wide arm with a
// 45° chamfer, channel that clamps the 20x20 rod with 2x2 M3 bolts.

include <wrist_params.scad>

leg_disc_r   = b6709[1] / 2 + 3.5;
leg_w        = 30;
leg_wall     = 5.6;          // channel side walls, measured from the channel
leg_pocket_r = b6709[1] / 2 + 0.05 + fit;
leg_lip_r    = b6709[1] / 2 - 0.95;
bolt_d       = 3.15;
bolt_head_d  = 6.2;
bolt_y       = rod_bolt_pitch / 2;   // set to 0 to hit the centre slot of a slotted 2020 extrusion
bolt_z       = [rod_top - rod_bolt_top, rod_top - rod_bolt_top - rod_bolt_pitch];
bolt_seat_x  = 14;           // where the counterbore starts

// clearance swept by the yoke (x, r), revolved about X: the ring, then the
// corners of the blocks either side of it (from yoke_r - 10 outwards)
leg_arch_clear = 1.5;
leg_block_r = norm([yoke_block_y, yoke_h / 2]);
leg_arch = concat(
    [for (x = [0 : 1 : leg_x[0]]) [x, max(yoke_sweep_r(x), x >= yoke_r - 11 ? leg_block_r : 0) + leg_arch_clear]],
    [[leg_x[0], leg_block_r + leg_arch_clear]]);

module leg_body(hole_d) {
    x0 = leg_x[0]; x1 = leg_x[1];
    xin = rod_gap / 2 - leg_wall;
    difference() {
        union() {
            revolve_x([[x0, 0], [x0, leg_disc_r], [x1 - 2, leg_disc_r], [x1, leg_disc_r - 2], [x1, 0]]);
            along_y() linear_extrude(leg_w, center = true) mirror([0, 1, 0])
                polygon([[xin, leg_bottom], [14, leg_bottom],
                         [x1, leg_bottom + x1 - 14], [x1, 0], [xin, 0]]);
        }
        revolve_x(concat([[-1, 0], [-1, leg_arch[0][1]]], leg_arch, [[x0, 0]]));
        // bearing pocket, retaining lip, hole in the end wall
        revolve_x([[x0 - eps, 0], [x0 - eps, leg_pocket_r], [x0 + b6709[2], leg_pocket_r],
                   [x0 + b6709[2], leg_lip_r], [x0 + b6709[2] + 1, leg_lip_r], [x0 + b6709[2] + 1, hole_d / 2], [x1 + 1, hole_d / 2], [x1 + 1, 0]]);
        // rod channel
        translate([-1, -rod_gap / 2, leg_bottom - 1]) cube([rod_gap / 2 + 1, rod_gap, 60]);
        // M3 bolts into the rod, with head counterbores
        for (y = [-bolt_y, bolt_y], z = bolt_z) translate([0, y, z]) {
            translate([rod_gap / 2 - 1, 0, 0]) along_x() cylinder(d = bolt_d, h = bolt_seat_x - rod_gap / 2 + 1 + eps, $fn = 24);
            translate([bolt_seat_x, 0, 0]) along_x() cylinder(d = bolt_head_d, h = 40, $fn = 32);
        }
        children();
    }
}

// outer face down, bearing pocket up
module leg_print_pose() rotate([0, 90, 0]) translate([-leg_x[1], 0, 0]) children();
