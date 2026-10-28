include <BOSL2/std.scad>
include <BOSL2/screws.scad>
include <n5065-mounts.scad>

/*
 * N5065 motor mount that clamps onto a 20x20 rail and holds the motor on top of it.
 *
 * A sleeve slides over the rail. Its outer side continues up as a wall, and the
 * motor's front face bolts to the inside of that wall (screws go in from outside),
 * so the motor sits above the rail with its shaft pointing across, into the gap
 * between the rails. Like the lab 3 mount, a flat slab is cut out through the rail
 * centreline, leaving a top piece and a bottom cap. Four ears stick out at the split,
 * and an M3 screw down through each ear into a heat insert pulls the pieces together
 * and grips the rail: loosen them to slide the mount along the rail and tension the belt.
 *
 * Local frame: rail along X centred on y=0, z=0. The wall is on -Y, the motor
 * shaft points to +Y. Used by elbow-assembly.scad; open this file on its own to
 * get the part in print orientation (standing on one end).
 */

$fn = $preview ? 32 : 128;

rail_size = 20;
clamp_clearance = 0.4;
clamp_wall = 6;
clamp_l = 70;
mount_t = 6;
cheek_t = 6;                      // side gussets from the wall to the sleeve top
mount_gap = 2.4;                  // slab removed between the two pieces

ear = [10, 9, 16];                // [along rail, sticking out, height across the split]
ear_inset = 8;                    // how far the ears sit in from the ends of the mount
couple_screw_diameter = 3;
heatinsert_diameter = 3.8;
heatinsert_length = 4;

tunnel = rail_size + clamp_clearance;
ring = tunnel + clamp_wall*2;
motor_z = ring/2 + 1 + n5065_motor_diameter()/2;     // 1 mm above the sleeve
wall_top = motor_z + n5065_motor_diameter()/2 + 4;

// for the assembly: where the motor ends up relative to the rail centre
function motor_mount_motor_z() = motor_z;
function motor_mount_front_y() = -tunnel/2;          // motor front face

module motor_mount() {
    m = n5065_motor_diameter();
    cheek_depth = tunnel + clamp_wall;
    couple = [clamp_l - ear[0] - ear_inset*2, ring + ear[1]];     // M3 spacing, centred in the ears

    diff() {
        // sleeve around the rail
        cuboid([clamp_l, ring, ring]);
        // upright wall carrying the motor
        translate([0, -ring/2, -ring/2]) cuboid([clamp_l, mount_t, wall_top + ring/2], anchor=FWD+BOT, rounding=4, edges=[TOP+LEFT, TOP+RIGHT]);
        // side gussets from the wall down to the top of the sleeve
        for (x = [-clamp_l/2, clamp_l/2 - cheek_t]) hull() {
            translate([x, -tunnel/2, ring/2]) cuboid([cheek_t, 1, motor_z - ring/2], anchor=LEFT+FWD+BOT);
            translate([x, -tunnel/2, ring/2]) cuboid([cheek_t, cheek_depth, 1], anchor=LEFT+FWD+BOT);
        }
        // screw ears on both sides, across the split
        // only the outer corners are rounded, the side against the sleeve stays square
        grid_copies(couple, n=2) let(out = $pos.y < 0 ? FWD : BACK)
            cuboid(ear, rounding=2, edges=[out+LEFT, out+RIGHT]);

        tag("remove") {
            // rail tunnel
            cuboid([clamp_l + 2, tunnel, tunnel]);
            // split into a top piece and a bottom cap
            cuboid([clamp_l + 2, ring + ear[1]*2 + 2, mount_gap]);
            // 4x M3 down through the ears, heat insert in the bottom of each lower ear
            grid_copies(couple, n=2) {
                screw_hole(str("M", couple_screw_diameter), l=ear[2] + 0.02);
                down(ear[2]/2 + 0.01) zcyl(d=heatinsert_diameter, h=heatinsert_length, anchor=BOT, chamfer1=-0.6);
            }
            // pocket for the motor front mount
            translate([0, -ring/2 + mount_t/2, motor_z]) cuboid([m, mount_t + 1, m]);
        }
    }
    // N5065 front face pattern, bricks pointing at the motor (+Y)
    translate([0, -ring/2 + mount_t/2, motor_z]) xrot(90) n5065_front_mount(thickness=mount_t, circle=false);
}

yrot(90) motor_mount();
