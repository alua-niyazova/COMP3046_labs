include <BOSL2/std.scad>
include <BOSL2/screws.scad>
include <n5065-mounts.scad>
include <htd-pulley.scad>

/*
 * HTD 5M belt pulleys for the elbow, 10 mm belt.
 *
 * Set the size of each pulley with motor_pulley_r and shaft_pulley_r (pitch radius,
 * where the belt runs). The tooth count is the nearest whole number of 5 mm teeth.
 *
 * motor_pulley: same as lab3/homework-reference.scad. No hub, 1.5 mm flanges like the shaft pulley, bolts
 *   straight onto the rear of the N5065 with 4 flat-head M3 from the outside face.
 * shaft_pulley: square bore on the 20x20 tube.
 *   Square hub so the M3 heads and nuts sit flat. Two M3 go straight through the
 *   hub and the tube and out the other side, at right angles to each other.
 *
 * Both print flat, the motor pulley with the motor side down.
 * Screws are ghosts in the "both" view, they are not printed.
 */

part = "both"; // [both, motor_pulley, shaft_pulley]

motor_pulley_r = 18;   // [17.5:0.w5:40] pitch radius, mm (27 = 34T like the homework)
shaft_pulley_r = 40;   // [24:1:90] pitch radius, mm

$fn = $preview ? 32 : 128;

belt_type = "5M";
belt_pitch = 5;
belt_width = 10;
band_h = belt_width + 1.5;        // toothed part between the flanges (htd_pulley adds 1.5)

motor_flange = 1.5;               // same as the shaft pulley
motor_teeth = round(2*PI*motor_pulley_r/belt_pitch);

shaft_flange = 1.5;
shaft_teeth = round(2*PI*shaft_pulley_r/belt_pitch);
shaft_size = 20;
square_clearance = 0.4;
hub_wall = 4;
shaft_hub = [shaft_size + square_clearance + hub_wall*2, 16];   // [square side, height]
hub_screw_z = [4.5, 11.5];        // up from the bottom of the hub
screw_d = 3.4;                    // M3 clearance

function htd_pitch_d(t) = t * belt_pitch / PI;
// root of the teeth (5M: 0.5715 pitch line offset + 2.06 tooth depth)
function htd_root_r(t) = htd_pitch_d(t)/2 - 0.5715 - 2.06;

// the 4 rear M3 sit on a 7,7 square; flat heads reach r ~12.9
assert(htd_root_r(motor_teeth) >= 14.5, "motor pulley too small for the rear motor screws");
assert(shaft_teeth >= 30, "shaft pulley too small for the square hub");
echo(str("motor pulley ", motor_teeth, "T, pitch r ", htd_pitch_d(motor_teeth)/2,
         " | shaft pulley ", shaft_teeth, "T, pitch r ", htd_pitch_d(shaft_teeth)/2,
         " | ratio ", shaft_teeth/motor_teeth));

// lightening holes in the web between the hub corners and the teeth, if there is room
web = [shaft_hub[0]/sqrt(2) + 3, htd_root_r(shaft_teeth) - 3];
hole_d = web[1] - web[0];
hole_r = (web[0] + web[1])/2;
hole_n = min(6, floor(2*PI*hole_r/(hole_d + 5)));

function motor_pulley_pitch_d() = htd_pitch_d(motor_teeth);
function shaft_pulley_pitch_d() = htd_pitch_d(shaft_teeth);
function motor_pulley_teeth() = motor_teeth;
function shaft_pulley_teeth() = shaft_teeth;
function motor_pulley_h() = motor_flange*2 + band_h;
// belt centre line, up from the bottom of each pulley
function motor_pulley_belt_z() = motor_flange + band_h/2;
function shaft_pulley_belt_z() = shaft_flange + band_h/2;
function pulley_belt_width() = belt_width;
function pulley_belt_pitch() = belt_pitch;

// TOP goes against the rear of the motor, screws go in from BOT
module motor_pulley() {
    diff() htd_pulley(type=belt_type, teeth=motor_teeth, belt_width=belt_width, hub_h=0, flange_thickness=motor_flange, anchor=BOT) {
        tag("remove") attach(TOP, BOT, inside=true) n5065_rear_bore();
        tag("remove") attach(BOT, TOP, inside=true) n5065_rear_screws(l=belt_width + motor_flange*2 + 1.5);
    }
}

module shaft_pulley() {
    bore = shaft_size + square_clearance;
    diff() htd_pulley(type=belt_type, teeth=shaft_teeth, belt_width=belt_width, bore_d=bore, d_flat=bore,
                      hub_h=0, flange_thickness=shaft_flange, set_screw_d=0, anchor=BOT) {
        position(TOP) cuboid([shaft_hub[0], shaft_hub[0], shaft_hub[1]], rounding=1, edges="Z", anchor=BOT);
        tag("remove") cuboid([bore, bore, 100]);
        // two M3 through the hub and the tube, one each way
        tag("remove") position(TOP) {
            up(hub_screw_z[0]) xcyl(d=screw_d, h=shaft_hub[0] + 2);
            up(hub_screw_z[1]) ycyl(d=screw_d, h=shaft_hub[0] + 2);
        }
        if (hole_d >= 6) tag("remove") zrot_copies(n=hole_n, r=hole_r) cyl(d=hole_d, h=100);
    }
}

// not printed, ghosts only
module shaft_pulley_screws() {
    up(shaft_flange*2 + band_h) {
        up(hub_screw_z[0]) xcyl(d=3, h=35);
        up(hub_screw_z[1]) ycyl(d=3, h=35);
    }
}

if (part == "both") {
    shaft_pulley();
    %shaft_pulley_screws();
    right(htd_pitch_d(shaft_teeth)/2 + htd_pitch_d(motor_teeth)/2 + 15) up(motor_pulley_h()) xrot(180) motor_pulley();
}
if (part == "motor_pulley") up(motor_pulley_h()) xrot(180) motor_pulley();
if (part == "shaft_pulley") shaft_pulley();
