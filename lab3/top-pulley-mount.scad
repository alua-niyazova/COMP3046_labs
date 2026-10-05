include <BOSL2/std.scad>
include <BOSL2/screws.scad>
include <htd-pulley.scad>


part = "assembly";

$fn = $preview ? 16 : 128;

// --- values copied from homework-reference.scad  ---
carriage_dim = [20, 40, 10];
lift_tube_od = 10;
lift_tube_length = 200;
mount_tube_clearance = 0.4;
mount_tube_od = 25;
mount_wall_thickness = 3 * 2;
mount_length = 58.5;              // n5065_motor_length()
motor_diameter = 50.4;            // n5065_motor_diameter()
motor_pulley_teeth = 34;
motor_pulley_flange = 5;
belt_width = 10;


tube_pos = [lift_tube_od/2, mount_length + (6+6+carriage_dim[0]+1.5)/2, mount_wall_thickness*2 + mount_tube_od]; // [5, 75.25, 37] bottom of tube
motor_pulley_pos = [0, mount_length + (motor_pulley_flange*2 + belt_width + 1.5)/2, -(4 + motor_diameter/2)];     // [0, 69.25, -29.2]
tube_top = tube_pos + [0, 0, lift_tube_length];
belt_offset = [motor_pulley_pos.x - tube_pos.x, 0];

// --- top pulley ---
top_pulley_teeth = 35;
top_pulley_flange = 2;            // thinner than the motor pulley, the idler needs no screw bosses
top_pulley_h = top_pulley_flange*2 + belt_width + 1.5;
function htd5m_pitch_d(t) = t * 5 / PI;
top_flange_r = htd5m_pitch_d(top_pulley_teeth)/2 - 0.5715 + 1.5; // outer radius + flange_overhang

bearing_od = 16;
bearing_h = 5;
bearing_clearance = 0.1;
axle_d = 5;                       // bearing bore (pulley side)
mount_bolt_d = 4;                 // M4 bolt through the mount cheeks
pulley_bore = 11;                 // clears the bearing inner race, supports the outer race

// --- mount ---
m2_screw_diameter = 2;
m2_screw_interval = 20;           // same spacing as the M3 holes in the base
m2_heatinsert_diameter = 3.2;
m2_heatinsert_length = 3;

socket_wall = 4;
socket_depth = 45;                // how far the tube goes into the cap
m2_screw_top = 10;                // depth of the upper M2 hole below the top of the tube (was 6)
m2_screw_z = [-m2_screw_top, -m2_screw_top - m2_screw_interval];
socket_hole = lift_tube_od + mount_tube_clearance;
// 3-sided U channel: walls on -X, -Y, +Y; open on +X for the rail
socket_x = [-socket_hole/2 - socket_wall, socket_hole/2];
socket_y = [-socket_hole/2 - socket_wall, socket_hole/2 + socket_wall];
top_plate = 4;
washer_gap = 1;                   // M5 washer between pulley and each cheek
cheek_t = 5;
cheek_w = 45;                      // base length of the triangular cheeks (was 24)
cheek_top_d = 16;                 // rounded top around the axle
axle_z = top_plate + top_flange_r + 2;       // 2 mm between flange and the top plate

cheek_y = [belt_offset.y - top_pulley_h/2 - washer_gap - cheek_t/2,
           belt_offset.y + top_pulley_h/2 + washer_gap + cheek_t/2];

// belt length check (open belt)
centre_distance = tube_top.z + axle_z - motor_pulley_pos.z;
d1 = htd5m_pitch_d(motor_pulley_teeth);
d2 = htd5m_pitch_d(top_pulley_teeth);
belt_length = 2*centre_distance + PI*(d1 + d2)/2 + pow(d2 - d1, 2)/(4*centre_distance);
echo("top pulley pitch diameter: ", d2, " (motor: ", d1, ")");
echo("centre distance: ", centre_distance);
echo("belt length: ", belt_length, " -> HTD 5M belt teeth: ", belt_length/5);
echo("mount goes at (global): ", tube_top);

module top_pulley(anchor=CENTER, spin=0, orient=UP) {
    diff() htd_pulley(type="5M", teeth=top_pulley_teeth, belt_width=belt_width,
                      bore_d=pulley_bore, d_flat=pulley_bore, hub_h=0,
                      flange_thickness=top_pulley_flange, set_screw_d=0,
                      anchor=anchor, spin=spin, orient=orient) {
        // the outer diff() hides htd_pulley's own bore, so cut it again here
        tag("remove") cyl(d=pulley_bore, h=top_pulley_h + 1);
        tag("remove") attach(TOP, TOP, inside=true) cyl(d=bearing_od + bearing_clearance, h=bearing_h, chamfer2=-0.6);
        tag("remove") attach(BOT, BOT, inside=true) cyl(d=bearing_od + bearing_clearance, h=bearing_h, chamfer1=-0.6);
        children();
    }
}

module top_mount() {
    plate_x = [min(socket_x[0], belt_offset.x - cheek_w/2), max(socket_x[1], belt_offset.x + cheek_w/2)];
    plate_y = [min(socket_y[0], cheek_y[0] - cheek_t/2), max(socket_y[1], cheek_y[1] + cheek_t/2)];

    diff() {
        // U channel that slides over the top of the tube, open on +X for the MGN9 rail
        translate([socket_x[0], socket_y[0], 0])
            cuboid([socket_x[1]-socket_x[0], socket_y[1]-socket_y[0], socket_depth], anchor=TOP+LEFT+FWD,
                   rounding=1, edges=[FWD+LEFT, BACK+LEFT]);

        // 2x M2 into the tube from the LEFT side (opposite the rail), like the base
        for (z = m2_screw_z) tag("remove") translate([socket_x[0], 0, z])
            screw_hole(str("M", m2_screw_diameter), l=socket_wall + lift_tube_od/2, anchor=TOP, orient=LEFT) {
                attach(TOP, TOP, inside=true) cyl(d=m2_heatinsert_diameter, h=m2_heatinsert_length, chamfer2=-0.6);
            }
        // tube pocket, running out through the open +X side
        tag("remove") left(socket_hole/2) down(socket_depth + 0.01)
            cuboid([socket_hole + 1, socket_hole, socket_depth], anchor=BOT+LEFT);

        // top plate
        translate([plate_x[0], plate_y[0], 0])
            cuboid([plate_x[1]-plate_x[0], plate_y[1]-plate_y[0], top_plate], anchor=BOT+LEFT+FWD, rounding=1, edges="Z");

        // two cheeks holding the axle, in line with the motor pulley
        for (y = cheek_y) translate([belt_offset.x, y, 0]) {
            hull() {
                cuboid([cheek_w, cheek_t, top_plate], anchor=BOT);
                up(axle_z) ycyl(d=cheek_top_d, h=cheek_t);
            }
            tag("remove") up(axle_z) ycyl(d=mount_bolt_d + 0.3, h=cheek_t + 1);
        }
    }
}

module placed_pulley() {
    translate([belt_offset.x, belt_offset.y, axle_z]) top_pulley(orient=BACK);
}

if (part == "mount") top_mount();
if (part == "pulley") top_pulley();
if (part == "assembly") {
    top_mount();
    color("orange") placed_pulley();
}
