// Belt clearance check for the twisting roll runs.
//
// Models each roll run as a real HTD 5M cross-section (roll_belt_w x 3.8 mm) that
// twists linearly from the yoke idler to the leg idler, at the chosen pitch.
// The belt is grown by `clearance` on every side and intersected with `part`.
//
// Render (F6). An EMPTY result means the belt clears that part by at least
// `clearance` mm. Anything left over shows where it would rub.
//   part = "both_runs" checks run A against run B (gap between them = 2 x clearance)
//   part = "show"      just draws the twisted belts in the assembly pose

use <yoke.scad>
use <cup.scad>
use <leg_roll.scad>
include <wrist_params.scad>

part = "leg";       // [show, yoke, cup, leg, both_runs]
pitch = 45;
clearance = 1;
slices = 16;

function rotx(p, a) = [p.x, p.y * cos(a) - p.z * sin(a), p.y * sin(a) + p.z * cos(a)];

// belt cross-section at pitch-line point p; teeth face along angle tn in the YZ plane
module belt_slice(p, tn, c) translate(p) rotate([tn - 90, 0, 0])
    translate([0, -roll_belt_w / 2 - c, -belt_back - c]) cube([0.01, roll_belt_w + 2 * c, belt_back + belt_tip + 2 * c]);

// run A (s = 1) teeth face -y_yoke at the yoke idler and down at the leg idler;
// run B (s = -1) teeth face +y_yoke and up. Both twist by (90 - pitch).
module roll_run(s, c = 0) {
    zl = leg_idler.y + idler_r + (s > 0 ? belt_tip : belt_back);
    p0 = rotx([yoke_idler.x, s * run_y, 0], pitch);
    p1 = [leg_idler.x, s * run_y, zl];
    t0 = (s > 0 ? 180 : 0) + pitch;
    dt = 90 - pitch;
    for (i = [0 : slices - 1]) hull() {
        belt_slice(p0 + (p1 - p0) * i / slices, t0 + dt * i / slices, c);
        belt_slice(p0 + (p1 - p0) * (i + 1) / slices, t0 + dt * (i + 1) / slices, c);
    }
}

module target() {
    if (part == "yoke") rotate([pitch, 0, 0]) yoke();
    if (part == "cup") rotate([pitch, 0, 0]) cup();
    if (part == "leg") leg_roll();
}

if (part == "show") {
    color("black") for (s = [-1, 1]) roll_run(s);
    %leg_roll();
    %rotate([pitch, 0, 0]) { yoke(); cup(); }
} else if (part == "both_runs") {
    intersection() { roll_run(1, clearance); roll_run(-1, clearance); }
} else {
    intersection() { target(); for (s = [-1, 1]) roll_run(s, clearance); }
}
