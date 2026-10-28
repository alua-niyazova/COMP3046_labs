// Yoke: ring holding the cup bearings, split at z = 0 into two halves so the
// bearings and cup can go in from the split face.
//   -X: solid pitch shaft that passes through the left leg; the pitch pulley
//       bolts onto its end with 3x M3.
//   +X: hollow stub for the two roll belt runs, with a window in the ring and
//       two idlers that steer the runs in from the drum.
// Halves are held by 4x M3x35 + nuts: two through the pitch block, and the two
// yoke idler axles. The leg bearings around the stubs also hold them together.

include <wrist_params.scad>

orient_for_print = true;   // both halves split face down, no support needed

yoke_seat_r = b6709[1] / 2 + 0.09 + fit;
yoke_lip_r  = b6709[1] / 2 - 0.7;
yoke_cav_r  = yoke_seat_r + 3.4;       // clearance round the drum, in the belt plane
stub_r      = b6709[0] / 2 - 0.05;
stub_sh_r   = b6709[0] / 2 + 1;        // shoulders on the inner race
stub_bore_r = stub_r - 3.45;
// x from, x to, half width y, height z
belt_window = [yoke_r - 20, yoke_r + 1, yoke_block_y - 1, idler_w + 2];
// x from, x to, half width y (corners must stay inside the legs' arch, see leg_base.scad)
roll_block  = [yoke_r - 10, yoke_r + 1, yoke_block_y];
pitch_block = [yoke_r - 10, yoke_r - 2, yoke_block_y];

/* [Split bolts] */
bolt_hole_d = 3.3;
bolt_head   = [6, 3.5];     // counterbore d, depth (top half)
bolt_nut    = [6.5, 3];     // hex across corners, depth (bottom half)
pitch_bolt  = [yoke_r - 5.5, yoke_block_y - 3.67];   // -X side (x, +/-y)

function yoke_bolts() = concat(
    [for (s = [-1, 1]) [yoke_idler.x, s * yoke_idler.y]],
    [for (s = [-1, 1]) [-pitch_bolt.x, s * pitch_bolt.y]]);

module yoke_interior() {
    h = yoke_h / 2;
    s = cup_bearing_z;
    w = b6709[2] / 2;
    rotate_extrude() polygon([
        [0, -h - 1], [yoke_lip_r, -h - 1], [yoke_lip_r, -s - w],
        [yoke_seat_r, -s - w], [yoke_seat_r, -s + w - 0.5], [yoke_cav_r - 0.4, -4], [yoke_cav_r, -3.6],
        [yoke_cav_r, 3.6], [yoke_cav_r - 0.4, 4], [yoke_seat_r, s - w + 0.5], [yoke_seat_r, s + w],
        [yoke_lip_r, s + w], [yoke_lip_r, h + 1], [0, h + 1]]);
}

// shoulder, retaining groove, shoulder, bearing seat (positive x)
x0 = leg_x[0];
stub_profile = [[x0 - 5 - eps, stub_sh_r], [x0 - 4, stub_r], [x0 - 2, stub_r], [x0 - 1, stub_sh_r - 0.02],
                [x0, stub_sh_r - 0.02], [x0, stub_r], [x0 + b6709[2], stub_r]];

module roll_stub() {
    translate([roll_block[0], -roll_block[2], -yoke_h / 2])
        cube([roll_block[1] - roll_block[0], 2 * roll_block[2], yoke_h]);
    revolve_x(concat([[x0 - 5 - eps, 0]], stub_profile, [[x0 + b6709[2], stub_bore_r + 2], [x0 + b6709[2], 0]]));
}

module pitch_stub() {
    e = pitch_shaft_end;
    translate([pitch_block[0], -pitch_block[2], -yoke_h / 2])
        cube([pitch_block[1] - pitch_block[0], 2 * pitch_block[2], yoke_h]);
    revolve_x(concat([[x0 - 5 - eps, 0]], stub_profile,
        [[x0 + b6709[2], pitch_shaft_r], [e - 0.5, pitch_shaft_r], [e, pitch_shaft_r - 0.5], [e, 0]]));
}

module yoke() {
    h = yoke_h / 2;
    r = yoke_r;
    c = yoke_chamfer;
    xe = x0 + b6709[2];
    difference() {
        union() {
            rotate_extrude() polygon([[0, -h], [r - c[0], -h], [r, -h + c[1]], [r, h - c[1]], [r - c[0], h], [0, h]]);
            roll_stub();
            mirror([1, 0, 0]) pitch_stub();
        }
        yoke_interior();
        // roll belt window in the ring
        translate([belt_window[0], -belt_window[2], -belt_window[3] / 2])
            cube([belt_window[1] - belt_window[0], 2 * belt_window[2], belt_window[3]]);
        // hollow roll stub
        revolve_x([[r - 3, 0], [r - 3, stub_bore_r], [xe - 2, stub_bore_r], [xe + eps, stub_bore_r + 2], [xe + eps, 0]]);
        // split bolts: head counterbore on top, nut trap underneath
        for (p = yoke_bolts()) translate([p.x, p.y, 0]) {
            cylinder(d = bolt_hole_d, h = yoke_h + 2, center = true, $fn = 24);
            translate([0, 0, h - bolt_head[1]]) cylinder(d = bolt_head[0], h = bolt_head[1] + 1, $fn = 32);
            translate([0, 0, -h - 1]) cylinder(d = bolt_nut[0], h = bolt_nut[1] + 1, $fn = 6);
        }
        // M3 holes for the pitch pulley (tap or self-tapping)
        for (i = [0 : 2]) rotate([i * 120, 0, 0])
            translate([-pitch_shaft_end - eps, 0, pitch_screw_pcd / 2]) rotate([0, 90, 0])
                cylinder(d = 2.5, h = 10, $fn = 20);
    }
}

module yoke_half(top) intersection() {
    yoke();
    translate([-150, -150, top ? 0 : -150]) cube([300, 300, 150]);
}

if (orient_for_print) {
    translate([0, yoke_r + 3, 0]) yoke_half(true);
    translate([0, -yoke_r - 3, 0]) rotate([180, 0, 0]) yoke_half(false);
} else yoke();
