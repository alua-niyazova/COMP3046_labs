// Grooved cable idler; holds two 7x3x3 bearings on a 3 mm pin. Print 4.

include <wrist_params.scad>

orient_for_print = true;

module idler() {
    difference() {
        cylinder(d = idler_d, h = idler_w, center = true);
        rotate_extrude() translate([idler_d / 2 + 1.5, 0]) circle(r = groove_r);
        cylinder(d = idler_bearing[1] + fit, h = idler_w + 1, center = true);
    }
}

if (orient_for_print) translate([0, 0, idler_w / 2]) idler();
else idler();
