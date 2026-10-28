include <BOSL2/std.scad>
include <BOSL2/screws.scad>
include <n5065-mounts.scad>
use <motor-mount_v1.scad>
use <shaft-collar.scad>
use <rail-mount.scad>
use <pulleys.scad>

/*
 * Elbow joint concept: 20x20 square tube rotating between the front ends of two
 * 500 mm rails, driven by an N5065 through a single HTD 5M belt stage.
 * The motor pulley bolts to the rear of the motor (as in lab3/homework-reference.scad).
 * The motor clamps onto rail 1 and sits on top of it (motor-mount_v1.scad).
 *
 * Frame: rails run along -X and end at x=0, rail 1 (drive side) is at -Y,
 * the shaft axis is parallel to Y. All dimensions are assumed.
 *
 * The square tube carries the torque (pulley has a square bore). Each end is a stub
 * axle: an M5 bolt goes through a 625 bearing in the rail mount and screws into a nut
 * trapped in the end plug, clamping the bearing's inner ring against the plug.
 * The bearings sit in the rail mounts (rail-mount.scad), which also ring the collars.
 * Nothing runs through the middle of the tube.
 *
 * Printed:   rail mount (x2, rail-mount.scad), motor_pulley + shaft_pulley (pulleys.scad), motor mount (motor-mount_v1.scad),
 *            shaft plug + shaft collar (x2 each, shaft-collar.scad)
 * Purchased: 20x20 rails + 20x20 shaft tube, 2x M5x35 socket head + M5 nut + small washer, 2x 625 bearing,
 *            N5065, 1x HTD 5M 10 mm closed belt (length echoed), 4x M4x35 + nut, 4x M3x30 + 2x M3x35 + nuts
 */

elbow_angle = 50;  // [0:100] 0 = forearm hanging down

$fn = $preview ? 32 : 128;

// --- frame (assumed) ---
rail_size = 20;
rail_wall = 1.5;
rail_length = 500;
rail_gap = 180;                   // inner gap between the rails
rail_in = rail_gap/2;             // 90, inner face of each rail
rail_out = rail_in + rail_size;   // 110, outer face of each rail

// --- shaft (square tube on two M5 stub axles) ---
shaft_size = 20;
shaft_wall = 1.5;
shaft_x = rail_mount_shaft_x();      // 22 past the rail ends, set by rail-mount.scad
square_clearance = 0.4;
shaft_end = rail_out - 1 - shaft_plug_flange();      // 107, tube runs from -107 to 107


// --- belt (HTD 5M, pulleys.scad) ---
belt_width = pulley_belt_width();
belt_pitch = pulley_belt_pitch();
belt_t = 3.8;
motor_teeth = motor_pulley_teeth();
shaft_teeth = shaft_pulley_teeth();
nominal_dx = 121;                 // roughly where the motor goes along the rail

// --- motor: on top of rail 1, see motor-mount_v1.scad ---
rail1_y = -(rail_in + rail_size/2);
// motor moved along the rail so a whole number of belt teeth fits
function open_belt(c, d1, d2) = 2*c + PI*(d1 + d2)/2 + pow(d2 - d1, 2)/(4*c);
function belt_centre(l, d1, d2) = let(b = l - PI*(d1 + d2)/2) (b + sqrt(b*b - 2*pow(d2 - d1, 2)))/4;
d_motor = motor_pulley_pitch_d();
d_shaft = shaft_pulley_pitch_d();
belt_teeth = round(open_belt(norm([nominal_dx, motor_mount_motor_z()]), d_motor, d_shaft)/belt_pitch);
motor_dx = sqrt(pow(belt_centre(belt_teeth*belt_pitch, d_motor, d_shaft), 2) - pow(motor_mount_motor_z(), 2));
motor_x = shaft_x - motor_dx;
motor_z = motor_mount_motor_z();
motor_pos = [motor_x, motor_z];
motor_front_y = rail1_y + motor_mount_front_y();
motor_rear_y = motor_front_y + n5065_motor_length();
belt_y = motor_rear_y + motor_pulley_h();       // outer face of the motor pulley
belt_plane = belt_y - motor_pulley_belt_z();
shaft_pulley_y = belt_plane + shaft_pulley_belt_z();   // its bottom face, lined up on the belt

// --- ratio / belt checks ---
ratio = shaft_teeth / motor_teeth;
centre_distance = norm(motor_pos - [shaft_x, 0]);
belt = open_belt(centre_distance, d_motor, d_shaft);
assert(centre_distance > (d_motor + d_shaft)/2 + 5, "pulleys too big for the centre distance");
if (motor_x + 35 > -45) echo("WARNING: motor mount runs into the rail mount, use smaller pulleys");
echo("ratio: ", ratio, " -> continuous ~", 0.2*ratio*0.9, " N·m, peak ~", 0.32*ratio*0.9, " N·m");
echo("belt: ", belt_teeth, " teeth HTD 5M = ", belt_teeth*belt_pitch, " mm, 10 mm wide, motor ", motor_dx, " mm from the shaft");
echo("free shaft length for the forearm: ", shaft_end - shaft_pulley_y, " mm");

// ---------------- purchased parts (for the assembly only) ----------------

module rails() color("silver") for (s = [-1, 1])
    translate([0, s*(rail_in + rail_size/2), 0]) rect_tube(size=rail_size, wall=rail_wall, h=rail_length, anchor=TOP, orient=RIGHT);

module belt(p1, d1, p2, d2, y) color("#222") translate([0, y, 0]) difference() {
    hull() { translate([p1[0], 0, p1[1]]) ycyl(d=d1 + belt_t, h=belt_width); translate([p2[0], 0, p2[1]]) ycyl(d=d2 + belt_t, h=belt_width); }
    hull() { translate([p1[0], 0, p1[1]]) ycyl(d=d1, h=belt_width + 1); translate([p2[0], 0, p2[1]]) ycyl(d=d2, h=belt_width + 1); }
}

module assembly() {
    rails();

    // shaft: square tube, plugs at both ends, M5 stub axles
    translate([shaft_x, 0, 0]) yrot(-elbow_angle) {
        color("lightsteelblue") rect_tube(size=shaft_size, wall=shaft_wall, h=shaft_end*2, anchor=CENTER, orient=BACK);
        // plug + collar + M5 stub axle at each end (shaft-collar.scad)
        for (s = [-1, 1]) mirror([0, s < 0 ? 1 : 0, 0]) back(shaft_end) {
            color("mediumseagreen") shaft_plug();
            color("gold") shaft_collar();
            color("silver") shaft_end_hardware();
        }
        color("orange") back(shaft_pulley_y) xrot(90) { shaft_pulley(); %shaft_pulley_screws(); }
        // next link, out of scope: just shows the swing
        %back(50) cuboid([shaft_size, shaft_size, 300], anchor=TOP);
    }

    // printed, fixed to the rails
    color("orange") for (s = [-1, 1]) mirror([0, s < 0 ? 1 : 0, 0]) back(rail_out) rail_mount();
    color("tomato") translate([motor_x, rail1_y, 0]) motor_mount();

    // motor
    color("dimgray") translate([motor_x, motor_front_y, motor_z]) ycyl(d=n5065_motor_diameter(), h=n5065_motor_length(), anchor=FWD);
    color("orange") translate([motor_x, belt_y, motor_z]) xrot(90) motor_pulley();

    belt([shaft_x, 0], d_shaft, motor_pos, d_motor, belt_plane);
}

assembly();
