// Belt-driven 2-DOF wrist (pitch + roll), assembled. View only.
//
// Printed: yoke (2 halves), cup, leg_pitch, leg_roll, pitch_pulley,
//          idler x4 (2 in the yoke, 2 on the roll leg)
// Hardware: 6709-2RS bearing x4 (45x55x6), 7x3x3 bearing x8 (2 per idler),
//           3 mm steel pin, 44 mm (roll leg idlers),
//           M3: 4x M3x35 + nuts (yoke halves; 2 are the yoke idler axles),
//               8x rod bolts, 3x pulley screws,
//           20x20 square rod, HTD 5M belts: roll 10 mm, pitch 10 mm (lengths in the console)
//
// Roll belt clearance over pitch -90..90 is checked with belt_check.scad.
// The belts are drawn as ghost centre lines; the motors and their pulleys
// are placeholders at motor_drop below the pitch axis.

use <yoke.scad>
use <cup.scad>
use <leg_pitch.scad>
use <leg_roll.scad>
use <idler.scad>
use <pitch_pulley.scad>
include <wrist_params.scad>

pitch = 45;     // [-90:90] yoke angle about X; the roll runs twist by (90 - pitch)
roll  = 0;      // cup angle about the roll axis
show_hardware = true;
show_belts    = true;

function rotx(p, a) = [p.x, p.y * cos(a) - p.z * sin(a), p.y * sin(a) + p.z * cos(a)];

module path(pts, d = 1.5) for (i = [0 : len(pts) - 2])
    hull() { translate(pts[i]) sphere(d = d, $fn = 8); translate(pts[i + 1]) sphere(d = d, $fn = 8); }

function arc(c, r, a0, a1, n = 24) = [for (i = [0 : n]) let(a = a0 + (a1 - a0) * i / n) c + r * [cos(a), sin(a)]];

module roll_belt() {
    t = roll_tangent();
    R = htd_rp(drum_teeth);
    rho = idler_r + belt_back;
    a1 = atan2(t[0].y, t[0].x);
    a2 = (atan2(t[1].y - yoke_idler.y, t[1].x - yoke_idler.x) + 360) % 360;
    lc = [leg_idler.x, leg_idler.y];
    lr = -leg_idler.y;
    rm = htd_rp(motor_teeth);
    xd = leg_idler.x + lr;
    // drum wrap, yoke frame
    path([for (p = arc([0, 0], R, a1, 360 - a1, 48)) rotx([p.x, p.y, 0], pitch)]);
    for (s = [-1, 1]) {
        yoke_pts = concat([[t[0].x, s * t[0].y, 0]],
                          [for (p = arc(yoke_idler, rho, a2, 270, 8)) [p.x, s * p.y, 0]]);
        path(concat([for (p = yoke_pts) rotx(p, pitch)],
                    [for (p = arc(lc, lr, 90, 0, 8)) [p.x, s * run_y, p.y]],
                    [[xd, s * rm, -motor_drop]]));
    }
    path([for (p = arc([0, -motor_drop], rm, 0, -180, 24)) [xd, p.x, p.y]]);
}

module pitch_belt() {
    x = -(pitch_pulley_x + pitch_fl_t + pitch_band_h / 2);
    r1 = htd_rp(pitch_teeth);
    rm = htd_rp(motor_teeth);
    path(concat([for (p = arc([0, 0], r1, 180, 0, 24)) [x, p.x, p.y]],
                [for (p = arc([0, -motor_drop], rm, 0, -180, 24)) [x, p.x, p.y]],
                [[x, -r1, 0]]));
}

module motor_pulley_ghost(x, w) translate([x, 0, -motor_drop]) along_x()
    cylinder(r = htd_ro(motor_teeth), h = band_h(w), center = true);

module hardware_fixed() {
    for (s = [-1, 1]) translate([s * (leg_x[0] + b6709[2] / 2), 0, 0]) along_x() bearing(b6709);
    for (s = [-1, 1]) translate([leg_idler.x, s * run_y, leg_idler.y]) rotate([90, 0, 0])
        for (z = [-1, 1]) translate([0, 0, z * (idler_w - idler_bearing[2]) / 2]) bearing(idler_bearing);
    color("lightgray") translate([leg_idler.x, 0, leg_idler.y]) rotate([90, 0, 0])
        cylinder(d = pin_d, h = 2 * (run_y + idler_w / 2 + 5), center = true, $fn = 16);
    color("gainsboro") translate([-rod_w / 2, -rod_w / 2, rod_top - rod_len]) cube([rod_w, rod_w, rod_len]);
}

module hardware_yoke() {
    for (s = [-1, 1]) {
        translate([0, 0, s * cup_bearing_z]) bearing(b6709);
        translate([yoke_idler.x, s * yoke_idler.y, 0])
            for (z = [-1, 1]) translate([0, 0, z * (idler_w - idler_bearing[2]) / 2]) bearing(idler_bearing);
    }
    // M3x35 split bolts, head flush with the top face
    color("dimgray") for (p = yoke_bolts()) translate([p.x, p.y, yoke_h / 2 - 3.5 - 35])
        cylinder(d = 3, h = 35, $fn = 16);
}

echo(str("roll belt: ", roll_belt_length(), " mm -> ", round(roll_belt_length() / belt_pitch), "T",
         " | pitch belt: ", pitch_belt_length(), " mm -> ", round(pitch_belt_length() / belt_pitch), "T",
         " (HTD 5M, roll ", roll_belt_w, " mm, pitch ", pitch_belt_w, " mm, motor_drop = ", motor_drop, ")"));

color("SteelBlue") leg_pitch();
color("SteelBlue") leg_roll();
color("orange") for (s = [-1, 1]) translate([leg_idler.x, s * run_y, leg_idler.y]) rotate([90, 0, 0]) idler();
rotate([pitch, 0, 0]) {
    color("LightSteelBlue") yoke();
    color("orange") for (s = [-1, 1]) translate([yoke_idler.x, s * yoke_idler.y, 0]) idler();
    color("Tomato") rotate([0, 0, roll]) cup();
    color("Gold") translate([-pitch_pulley_x, 0, 0]) rotate([0, -90, 0]) pitch_pulley();
    if (show_hardware) hardware_yoke();
}
if (show_hardware) {
    hardware_fixed();
    %motor_pulley_ghost(leg_idler.x - leg_idler.y, roll_belt_w);
    %motor_pulley_ghost(-(pitch_pulley_x + pitch_fl_t + pitch_band_h / 2), pitch_belt_w);
}
if (show_belts) color("black") { roll_belt(); pitch_belt(); }
