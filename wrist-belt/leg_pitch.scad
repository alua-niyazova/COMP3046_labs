// Pitch-side leg (left, x < 0). The yoke's pitch shaft passes through the end
// wall; the pitch pulley sits outside.

use <leg_base.scad>
include <wrist_params.scad>

orient_for_print = true;   // outer face on the bed, bearing pocket up

shaft_hole_d = 2 * pitch_shaft_r + 1;

module leg_pitch() mirror([1, 0, 0]) leg_body(shaft_hole_d);

if (orient_for_print) mirror([1, 0, 0]) leg_print_pose() leg_body(shaft_hole_d);
else leg_pitch();
