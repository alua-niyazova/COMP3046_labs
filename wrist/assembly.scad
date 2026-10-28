// Cable-driven 2-DOF wrist (pitch + roll), assembled.
// Parametric rebuild of end_effector.stl. Each part has its own file for
// printing; shared dimensions live in wrist_params.scad.
//
// Printed: yoke x1, cup x1, leg_right x1, leg_left x1, idler x4
// Hardware: 6807 bearing x4 (35x47x7), 7x3x3 bearing x8 (2 per idler),
//           3 mm steel pins, M3 bolts x8, 20x20 square rod

use <yoke.scad>
use <cup.scad>
use <leg_right.scad>
use <leg_left.scad>
use <idler.scad>
include <wrist_params.scad>

pitch = 45;     // yoke angle about X (the original STL is posed at ~45.9)
roll  = 0;      // cup angle about the roll axis
show_hardware = true;

module hardware_fixed() {
    for (s = [-1, 1]) {
        translate([s * (leg_x[0] + b6807[2] / 2), 0, 0]) along_x() bearing(b6807);
        translate([s * leg_idler[0], 0, leg_idler[1]]) rotate([90, 0, 0]) {
            for (z = [-1, 1]) translate([0, 0, z * idler_bearing[2] / 2]) bearing(idler_bearing);
            color("lightgray") cylinder(d = pin_d, h = 22, center = true, $fn = 16);
        }
    }
    color("gainsboro") translate([-rod_w / 2, -rod_w / 2, rod_top - rod_len]) cube([rod_w, rod_w, rod_len]);
}

module hardware_yoke() {
    for (s = [-1, 1]) {
        translate([0, 0, s * cup_bearing_z]) bearing(b6807);
        translate([s * yoke_idler[0], yoke_idler[1], 0]) {
            for (z = [-1, 1]) translate([0, 0, z * idler_bearing[2] / 2]) bearing(idler_bearing);
            color("lightgray") cylinder(d = pin_d, h = 21.8, center = true, $fn = 16);
        }
    }
}

color("SteelBlue") leg();
color("SteelBlue") leg_left();
color("orange") for (s = [-1, 1]) translate([s * leg_idler[0], 0, leg_idler[1]]) rotate([90, 0, 0]) idler();
rotate([pitch, 0, 0]) {
    color("LightSteelBlue") yoke();
    color("orange") for (s = [-1, 1]) translate([s * yoke_idler[0], yoke_idler[1], 0]) idler();
    color("Tomato") rotate([0, 0, roll]) cup();
    if (show_hardware) hardware_yoke();
}
if (show_hardware) hardware_fixed();
