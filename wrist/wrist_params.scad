// Shared parameters and helpers for the cable-driven wrist.
// Every part file includes this, so change values here.
//
// Frames (mm):
//   origin = intersection of the pitch and roll axes
//   pitch axis = X  (yoke turns in the two legs on 6807 bearings)
//   roll  axis = yoke Z (output cup turns in the yoke on 6807 bearings)
//   legs clamp onto a vertical 20x20 square rod along -Z

$fn = 96;

/* [Bearings] */
b6807 = [35, 47, 7];        // bore, OD, width
idler_bearing = [3, 7, 3];  // 7x3x3 (bore, OD, width), two per idler
fit = 0.0;                  // extra clearance added to bearing seats

/* [Cable] */
cable_plane_h = 7.84;   // height of the cable windows in the yoke (|z| < h/2)
groove_r      = 2;      // cable groove radius on cup drum and idlers

/* [Pins] */
pin_d      = 3;         // idler pins
yoke_pin_d = 2.46;      // yoke idler pin holes (press fit)

/* [Mounting rod] */
rod_w       = 20;       // square rod the legs clamp onto
rod_gap     = rod_w + 0.2;  // channel width between the two legs
rod_top     = -36;      // top of the rod below the pitch axis
rod_len     = 120;      // only used for the assembly view

/* [Positions shared between parts] */
yoke_idler = [30.05, 5.12];   // yoke idler pin (x, y) in each stub, yoke frame
leg_idler  = [41, -5.25];     // leg idler pin (x, z), fixed frame
leg_x      = [33, 44];        // leg disc inner / outer face
cup_bearing_z = 13;           // cup bearing centres at +/- this on the roll axis

/* [Idler] */
idler_d = 10.45;
idler_w = 2 * idler_bearing[2];

eps = 0.01;

// ---------------------------------------------------------------- helpers

module along_x() rotate([0, 90, 0]) children();
module along_y() rotate([-90, 0, 0]) children();

// revolve an (axial, r) profile around the X axis
module revolve_x(pts) along_x() rotate_extrude() polygon([for (p = pts) [p[1], p[0]]]);

module tube(d_in, d_out, h, center = false) difference() {
    cylinder(d = d_out, h = h, center = center);
    translate([0, 0, center ? 0 : -1]) cylinder(d = d_in, h = h + 2, center = center);
}

module bearing(b) color("silver") tube(b[0], b[1], b[2], center = true);
