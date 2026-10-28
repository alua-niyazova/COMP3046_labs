// Smooth flanged belt idler on two 7x3x3 bearings and a 3 mm pin. Print 4:
// 2 in the yoke, 2 on the roll leg.

include <wrist_params.scad>

orient_for_print = true;

module idler() {
    difference() {
        union() {
            cylinder(r = idler_r, h = idler_band, center = true);
            for (s = [-1, 1]) translate([0, 0, s * (idler_band + idler_fl_t) / 2])
                cylinder(r = idler_r + idler_flange, h = idler_fl_t, center = true);
        }
        cylinder(d = pin_d + 1, h = idler_w + 1, center = true, $fn = 24);
        // bearing seats from both faces
        for (s = [-1, 1]) translate([0, 0, s * (idler_w / 2 - idler_bearing[2] / 2 + eps)])
            cylinder(d = idler_bearing[1] + fit, h = idler_bearing[2] + eps, center = true, $fn = 32);
    }
}

if (orient_for_print) translate([0, 0, idler_w / 2]) idler();
else idler();
