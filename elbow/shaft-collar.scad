include <BOSL2/std.scad>

/*
 * The two printed parts at each end of the elbow shaft (x2 each).
 *
 * shaft_plug:   pushes into the end of the 20x20 square tube. An M5 nut drops into
 *   the hex pocket at its inner end before it goes in; the M5 stub axle comes in
 *   through the 625 bearing and screws into that nut. The small boss touches only
 *   the bearing's inner ring.
 * shaft_collar: slides onto the outside of the tube over the plug. Round outside so
 *   it can turn inside the rail mount, with two flats for the screw heads and nuts.
 *
 * Two M3 go through the collar, the tube and the plug and come out the other side,
 * one each side of the M5 bolt (bolt 5 mm, tube inside 17 mm).
 *
 * Local frame matches the assembly: shaft axis along Y, y=0 is the end of the tube,
 * +Y is outwards, flats facing +-X. Screws, nuts, bearing and tube are ghosts.
 */

part = "assembled"; // [assembled, both, collar, plug]
angle = 50;         // [0:100] forearm angle for the "assembled" view

$fn = $preview ? 32 : 128;

shaft_size = 20;
shaft_wall = 1.5;
square_clearance = 0.4;

// M5 stub axle
bolt_d = 5;
bolt_l = 35;
bolt_head = [8.5, 5];             // socket head [d, h]
nut_af = 8;
nut_h = 4;

// bearing plate in elbow-assembly.scad
plate_y = [3, 11];                // inside and outside faces, from the end of the tube
bearing_625 = [16, 5];            // [od, width], flush with the outside face

plug_flange = 2;
plug_depth = 20;
plug_boss_d = 7.5;
plug_boss_h = plate_y[1] - bearing_625[1] - plug_flange;   // up to the inner ring

collar_r = 17;                    // round outside
collar_l = 12;
flat_wall = 3;                    // wall left under each flat

// two M3 across the flats, halfway between the bolt and the inside of the tube wall
screw_d = 3.4;
screw_offset = (bolt_d/2 + shaft_size/2 - shaft_wall)/2;
screw_y = -collar_l/2;

function shaft_collar_r() = collar_r;
function shaft_collar_l() = collar_l;
function shaft_plug_flange() = plug_flange;
function shaft_plug_depth() = plug_depth;

module m3_holes() {
    for (z = [-1, 1]) translate([0, screw_y, z*screw_offset]) xcyl(d=screw_d, h=collar_r*3);
}

module shaft_collar() {
    bore = shaft_size + square_clearance;
    flat_x = bore/2 + flat_wall;
    difference() {
        back(screw_y) xrot(90) linear_extrude(collar_l, center=true) difference() {
            intersection() {
                circle(r=collar_r);
                square([flat_x*2, collar_r*2], center=true);
            }
            square(bore, center=true);
        }
        m3_holes();
    }
}

module shaft_plug() {
    inner = shaft_size - shaft_wall*2 - 0.2;
    difference() {
        union() {
            cuboid([inner, plug_depth, inner], chamfer=0.6, edges=FWD, anchor=BACK);
            cuboid([shaft_size, plug_flange, shaft_size], rounding=1, edges="Y", anchor=FWD);
            back(plug_flange) ycyl(d=plug_boss_d, h=plug_boss_h, anchor=FWD);
        }
        ycyl(d=bolt_d + 0.3, h=100);
        // nut pocket, open at the inner end
        fwd(plug_depth + 0.01) ycyl(d=(nut_af + 0.3)/cos(30), h=nut_h + 0.5, $fn=6, anchor=FWD);
        m3_holes();
    }
}

// not printed, ghosts only
module shaft_end_hardware() {
    for (z = [-1, 1]) translate([0, screw_y, z*screw_offset]) xcyl(d=3, h=30);
    back(plate_y[1]) {
        ycyl(d=bolt_head[0], h=bolt_head[1], anchor=FWD);
        ycyl(d=bolt_d, h=bolt_l, anchor=BACK);
        tube(od=bearing_625[0], id=bolt_d, h=bearing_625[1], orient=BACK, anchor=TOP);
    }
    fwd(plug_depth) ycyl(d=nut_af/cos(30), h=nut_h, $fn=6, anchor=FWD);
}

module collar_assembled(a) {
    yrot(-a) {
        color("gold") shaft_collar();
        color("mediumseagreen") shaft_plug();
        %shaft_end_hardware();
        %rect_tube(size=shaft_size, wall=shaft_wall, h=60, anchor=BOT, orient=FWD);
        %fwd(40) cuboid([shaft_size, shaft_size, 120], anchor=TOP);
    }
    // bearing plate (fixed)
    %translate([-85, plate_y[0], -30]) cuboid([105, plate_y[1] - plate_y[0], 60], anchor=LEFT+FWD+BOT);
}

if (part == "assembled") collar_assembled(angle);
// print orientation: collar on its end face, plug standing on the spigot
if (part == "both") {
    left(25) xrot(90) back(collar_l) shaft_collar();
    right(25) xrot(90) back(plug_depth) shaft_plug();
}
if (part == "collar") xrot(90) back(collar_l) shaft_collar();
if (part == "plug") xrot(90) back(plug_depth) shaft_plug();
