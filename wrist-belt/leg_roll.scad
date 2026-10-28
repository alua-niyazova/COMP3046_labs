// Roll-side leg (right, x > 0) with the idler mount built in. The roll belt
// runs leave through the end wall along the pitch axis, pass over two idlers
// on one 3 mm pin along Y, and drop down to the roll motor.

use <leg_base.scad>
include <wrist_params.scad>

orient_for_print = true;   // see print_pose() below

belt_hole_d = 2 * (run_y + norm([roll_belt_w / 2, belt_tip]) + 1.5);   // room for both runs twisting
mount_cheek_t = 4;
mount_cheek_y = run_y + idler_w / 2 + 1;   // inner face of each cheek, from y = 0
mount_z     = [-25, -9];                    // where the cheeks meet the leg face
mount_rib_t = 3;                            // centre rib between the two idlers
mount_rib_z = [-30, -20];                   // rib stays below the lower run, which crosses y = 0 at pitch +/-90
mount_rib_rise = 8;                         // rib rises to the pin over this last stretch
mount_boss_r = 5;
mount_embed  = 3;                           // cheeks run this far into the leg

module idler_mount() {
    x1 = leg_x[1];
    w = mount_cheek_y + mount_cheek_t;
    module root(z, t) translate([x1 - mount_embed, 0, z[0]]) cube([mount_embed, t, z[1] - z[0]]);
    module boss(t) translate([leg_idler.x, 0, leg_idler.y]) along_y() cylinder(r = mount_boss_r, h = t, $fn = 48);
    // two cheeks and a centre rib, all vertical so they print without support
    for (y = [mount_cheek_y, -w]) translate([0, y, 0]) hull() { root(mount_z, mount_cheek_t); boss(mount_cheek_t); }
    module knee() translate([leg_idler.x - mount_rib_rise - 1, 0, mount_rib_z[0]])
        cube([1, mount_rib_t, mount_rib_z[1] - mount_rib_z[0]]);
    translate([0, -mount_rib_t / 2, 0]) {
        hull() { root(mount_rib_z, mount_rib_t); knee(); }
        hull() { knee(); boss(mount_rib_t); }
    }
}

module leg_roll() {
    difference() {
        union() {
            leg_body(belt_hole_d);
            idler_mount();
        }
        translate([leg_idler.x, 0, leg_idler.y]) rotate([90, 0, 0])
            cylinder(d = pin_hole_d, h = 2 * (mount_cheek_y + mount_cheek_t) + 2, center = true, $fn = 24);
    }
}

// standing on the flat bottom of the arm, as assembled
module print_pose() translate([0, 0, -leg_bottom]) children();

if (orient_for_print) print_pose() leg_roll();
else leg_roll();
