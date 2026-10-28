include <BOSL2/std.scad>
use <shaft-collar.scad>

/*
 * Rail mount at the front end of each rail (x2, flipped for rail 1).
 *
 * Hugs the rail from the outside: top, bottom and the outer face, open on the
 * inner side. Two M4 go down through the top, the rail and the bottom (Z axis)
 * with nuts.
 * Past the end of the rail only the outer wall carries on, out to the 625 bearing
 * for the M5 stub axle (pressed in from outside against a lip). The shaft end
 * stays inside the rail line and does not go into the mount.
 *
 * Local frame: rail along -X ending at x=0, its outer face at y=0 (rail fills
 * y=-20..0), shaft axis parallel to Y at x=shaft_x, z=0 is the rail centre.
 */

part = "assembled"; // [assembled, mount]
angle = 50;         // [0:100] forearm angle for the "assembled" view

$fn = $preview ? 32 : 128;

rail_size = 20;
rail_clearance = 0.3;
tube_end_gap = 3;                 // end of the square tube to the rail's outer face

// as close to the rail end as the collar allows (collar + M3 heads reach ~18.2)
shaft_x = 22;

hug_l = 45;                       // along the rail
wall = 4;                         // top and bottom of the clamp
side_t = 8;                       // outer wall, holds the bearing
bearing_boss_r = 12;              // wall around the bearing

bearing_625 = [16, 5];            // [od, width], flush with the outside face
bearing_lip_d = 12;               // stops the bearing being pushed in

screw_x = [-33, -12];
screw_y = -rail_size/2;           // rail centre
screw_d = 4.4;                    // M4 clearance

clamp_h = rail_size + rail_clearance*2 + wall*2;

function rail_mount_shaft_x() = shaft_x;

module rail_mount() {
    difference() {
        union() {
            // outer wall: full height over the rail, tapers to the bearing
            back(side_t) xrot(90) linear_extrude(side_t) hull() {
                translate([-hug_l, -clamp_h/2]) square([hug_l, clamp_h]);
                translate([shaft_x, 0]) circle(r=bearing_boss_r);
            }
            // top and bottom
            for (z = [-1, 1]) up(z*(clamp_h - wall)/2) cuboid([hug_l, rail_size, wall], anchor=RIGHT+BACK);
        }
        translate([0, -rail_size/2, 0]) cuboid([hug_l*2 + 2, rail_size + rail_clearance*2, rail_size + rail_clearance*2], anchor=RIGHT);
        // bearing pocket from the outside, lip on the inside
        translate([shaft_x, side_t, 0]) ycyl(d=bearing_625[0], h=bearing_625[1]*2);
        translate([shaft_x, 0, 0]) ycyl(d=bearing_lip_d, h=100);
        // M4 down through the clamp and the rail
        for (x = screw_x) translate([x, screw_y, 0]) zcyl(d=screw_d, h=100);
    }
}

module mount_assembled(a) {
    color("orange") rail_mount();
    %translate([0, -rail_size/2, 0]) cuboid([150, rail_size, rail_size], anchor=RIGHT);
    // shaft end, see shaft-collar.scad
    translate([shaft_x, -tube_end_gap, 0]) yrot(-a) {
        color("gold") shaft_collar();
        color("mediumseagreen") shaft_plug();
        %shaft_end_hardware();
        %rect_tube(size=20, wall=1.5, h=60, anchor=BOT, orient=FWD);
    }
    %for (x = screw_x) translate([x, screw_y, 0]) zcyl(d=4, h=clamp_h + 6);
}

if (part == "assembled") mount_assembled(angle);
// print orientation: outer wall on the bed, rail channel open upwards
if (part == "mount") up(side_t) xrot(-90) rail_mount();
