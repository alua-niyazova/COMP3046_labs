include <BOSL2/std.scad>
include <BOSL2/gears.scad>
include <htd-pulley.scad>

// HTD5M drive pulley and idler — 10 mm width belt.
// Adapted from hardware/common/htd-pulley.scad for the Week 3 BR lift axis.
// Belt: HTD5M 10 mm width. Motor: N5065 (8 mm shaft).

$fn = $preview ? 16 : 64;

belt_width = 10;     // HTD5M 10 mm width belt
bore       = 8;      // N5065 shaft diameter

// --- Drive pulley (20T) ---
// HTD5M 20T pitch radius = (20 × 5) / (2π) ≈ 15.92 mm
module drive_pulley() htd_pulley(
    type       = "5M",
    teeth      = 20,
    belt_width = belt_width,
    bore_d     = bore,
    d_flat     = bore,    // round shaft (no flat)
    hub_d      = 20,
    hub_h      = 7,
    flange_thickness = 1.5,
    flange_overhang  = 1.5,
    set_screw_d  = 3.2,
    anchor     = BOTTOM
);

// --- Idler pulley (20T, flange) ---
// The idler uses an 8 mm OD × 3 mm ID × 4 mm bearing and an M3 screw shaft.
idler_bearing_od = 8;
idler_bearing_id = 3;
idler_bearing_h  = 4;
idler_shaft_d    = 3;
idler_shaft_h    = 18;

module idler() htd_pulley(
    type       = "5M",
    teeth      = 20,
    belt_width = belt_width,
    bore_d     = idler_bearing_od,
    d_flat     = idler_bearing_od,
    hub_d      = 18,
    hub_h      = 7,
    flange_thickness = 1.5,
    flange_overhang  = 1.5,
    set_screw_d  = 0,
    anchor     = BOTTOM
);

module idler_bearing() {
    diff("bore") {
        cyl(d=idler_bearing_od, h=idler_bearing_h, anchor=BOTTOM);
        tag("bore")
            cyl(d=idler_bearing_id, h=idler_bearing_h + 0.2, anchor=BOTTOM);
    }
}

module idler_shaft() {
    cyl(d=idler_shaft_d, h=idler_shaft_h, anchor=CENTER);
}

module idler_assembly() {
    idler();
    up(18)
        idler_bearing();
    up(18)
        idler_shaft();
}

drive_pulley();
right(50) idler_assembly();
