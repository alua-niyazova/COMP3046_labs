// Shared parameters and helpers for the belt-driven wrist.
// Every part file includes this, so change values here.
//
// Frames (mm):
//   origin = intersection of the pitch and roll axes
//   pitch axis = X  (yoke turns in the two legs on 6709 bearings)
//   roll  axis = yoke Z (cup turns in the yoke on 6709 bearings)
//   legs clamp onto a vertical 20x20 square rod along -Z
//   pitch side = -X (pulley outside the left leg)
//   roll side  = +X (belt leaves through the hollow right stub)
//
// Roll belt path: cup drum -> yoke idler -> along the pitch axis through the
// right stub -> leg idler -> down to the roll motor, and back the same way on
// the other side. Both runs lie along the pitch axis, so pitching the yoke only
// twists them and does not turn the cup.

$fn = 96;

/* [Bearings] */
b6709 = [45, 55, 6];        // main bearings, 6709-2RS (bore, OD, width), x4
idler_bearing = [3, 7, 3];  // 7x3x3 (bore, OD, width), two per idler
fit = 0.0;                  // extra clearance added to bearing seats

/* [HTD 5M belt] */
belt_pitch = 5;
roll_belt_w  = 10;
pitch_belt_w = 10;         // same as elbow/pulleys.scad
function band_h(w) = w + 1.5;   // toothed band on pulleys, as in elbow/pulleys.scad
roll_band_h  = band_h(roll_belt_w);
pitch_band_h = band_h(pitch_belt_w);
htd_pld    = 0.5715;        // pitch line to pulley outer diameter
htd_depth  = 2.06;          // tooth depth
htd_groove_r = 1.49;
belt_back  = 1.17;          // pitch line to back of belt
belt_tip   = htd_pld + htd_depth;  // pitch line to tooth tips

drum_teeth  = 30;           // roll drum on the cup
pitch_teeth = 60;           // pitch pulley on the yoke shaft; 3:1 with a 20T motor pulley
motor_teeth = 20;           // motor pulleys (for belt lengths and the assembly view)
motor_drop  = 150;          // motor shafts below the pitch axis

/* [Idlers] */
idler_r      = 5;           // belt contact radius (smooth)
idler_flange = 1.5;         // flange overhang
idler_band   = roll_belt_w + 1;
idler_fl_t   = 1;
idler_w      = idler_band + 2 * idler_fl_t;

/* [Yoke] */
yoke_r        = b6709[1] / 2 + 6.5;  // outer radius of the ring
yoke_chamfer  = [2.7, 3.5];          // outer edge chamfer (radial, axial)
cup_bearing_z = 13.5;                 // cup bearing centres, +/- from the pitch axis
yoke_h        = 2 * (cup_bearing_z + b6709[2] / 2 + 2);   // 2 mm lips over the bearings

/* [Roll belt routing] */
run_y      = 10.5;          // pitch lines of the two roll runs, +/- from the pitch axis;
                            // the runs pass closest at mid-twist at pitch +/-90 (belt_check both_runs)
yoke_idler = [yoke_r - 6, run_y + belt_back + idler_r];   // yoke frame (x, +/-y), axis = yoke Z
// Twist length, yoke idler to leg idler. Edge stretch at 180 deg of twist
// (pitch -90) is about 3.4 % for a 10 mm belt; 80 would bring it to 1.9 %.
twist_len  = 60;
leg_idler  = [yoke_idler.x + twist_len, -(idler_r + (belt_tip + belt_back) / 2)];  // (x, z), axis = Y
yoke_block_y = yoke_idler.y + idler_r + idler_flange + 1.5;  // half width of the blocks either side of the ring

assert(run_y - idler_w / 2 >= 2, "roll leg idlers hit the centre rib, raise run_y");

/* [Pins] */
pin_d      = 3;
pin_hole_d = 2.9;           // press fit in the roll leg

/* [Mounting rod] */
rod_w   = 20;
rod_gap = rod_w + 0.2;
rod_len = 200;

/* [Shared positions] */
leg_x         = [yoke_r + 3, yoke_r + 3 + b6709[2] + 5];   // leg disc inner / outer face
pitch_pulley_x = leg_x[1] + 1;  // pulley starts this far out on the -X side
pitch_shaft_r  = b6709[0] / 2 - 2.5;   // shaft the pulley slides onto
pitch_screw_pcd = 24;       // 3x M3 axial screws, pulley -> shaft end
pitch_fl_t     = 1.5;
pitch_plate_t  = 3;
pitch_pulley_len = 2 * pitch_fl_t + pitch_band_h;
pitch_shaft_end  = pitch_pulley_x + pitch_pulley_len;

// furthest the yoke ring reaches from the pitch axis at x, over any pitch angle
function yoke_sweep_r(x) = sqrt(max(0, pow(yoke_r, 2) + pow(yoke_h / 2 - yoke_chamfer[1], 2) - x * x));
rod_top = -round(yoke_sweep_r(0) + 2.5);

// rod clamp on each leg: 2x2 M3, top row this far below the rod top
rod_bolt_pitch = 11;        // square, centre to centre
rod_bolt_top   = 6;
rod_bolt_edge  = 12;        // lower bolt centres to the bottom of the leg
leg_bottom = rod_top - rod_bolt_top - rod_bolt_pitch - rod_bolt_edge;

eps = 0.01;

// ---------------------------------------------------------------- HTD 5M

function htd_rp(t) = t * belt_pitch / (2 * PI);
function htd_ro(t) = htd_rp(t) - htd_pld;
function htd_root(t) = htd_ro(t) - htd_depth;

// toothed disc, same profile as elbow/htd-pulley.scad
module htd_teeth(t, h, center = false) {
    linear_extrude(h, center = center) difference() {
        circle(r = htd_ro(t), $fn = max(36, t * 4));
        for (i = [0 : t - 1]) rotate(i * 360 / t)
            translate([htd_ro(t) - htd_depth + htd_groove_r, 0]) circle(r = htd_groove_r, $fn = 16);
    }
}

// ---------------------------------------------------------------- roll belt geometry
// Crossed tangent from the drum (pitch circle) to the +y yoke idler.
// Returns [point on drum, point on idler], yoke frame, z = 0.

function roll_tangent() = let(
    c = yoke_idler, R = htd_rp(drum_teeth), rho = idler_r + belt_back,
    d = norm(c), b = atan2(c.y, c.x),
    g = b - acos(-(R + rho) / d), n = [cos(g), sin(g)])
    [-R * n, c + rho * n];

assert(norm(yoke_idler) > htd_rp(drum_teeth) + idler_r + belt_back,
       "yoke idler too close to the drum");
assert(norm(yoke_idler) > htd_ro(drum_teeth) + 1 + idler_r + idler_flange + 0.5,
       "yoke idler hits the drum flange");

function roll_belt_length() = let(
    t = roll_tangent(), R = htd_rp(drum_teeth), rho = idler_r + belt_back,
    a1 = atan2(t[0].y, t[0].x),
    drum = R * (360 - 2 * a1) * PI / 180,
    seg = norm(t[1] - t[0]),
    ia = 270 - (atan2(t[1].y - yoke_idler.y, t[1].x - yoke_idler.x) + 360) % 360,
    idl = rho * ia * PI / 180,
    xrun = leg_idler.x - yoke_idler.x,
    lrho = -leg_idler.y,
    leg = lrho * PI / 2,
    rm = htd_rp(motor_teeth),
    down = norm([motor_drop + leg_idler.y, rm - run_y]),
    mot = PI * rm)
    drum + mot + 2 * (seg + idl + xrun + leg + down);

function pitch_belt_length() = let(r1 = htd_rp(pitch_teeth), r2 = htd_rp(motor_teeth), c = motor_drop)
    2 * c + PI * (r1 + r2) + pow(r1 - r2, 2) / c;

// ---------------------------------------------------------------- helpers

module along_x() rotate([0, 90, 0]) children();
module along_y() rotate([-90, 0, 0]) children();

// revolve an (axial, r) profile around the X axis
module revolve_x(pts) along_x() rotate_extrude() polygon([for (p = pts) [p[1], p[0]]]);

module tube(d_in, d_out, h, center = false) difference() {
    cylinder(d = d_out, h = h, center = center);
    translate([0, 0, center ? 0 : -1]) cylinder(d = d_in, h = h + 2, center = center);
}

module bearing(b) color("silver") render() tube(b[0], b[1], b[2], center = true);
