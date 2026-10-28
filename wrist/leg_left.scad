// Left-hand leg: mirror image of leg_right.scad.

use <leg_right.scad>
include <wrist_params.scad>

orient_for_print = true;   // outer face on the bed, bearing pocket up

module leg_left() mirror([1, 0, 0]) leg();

if (orient_for_print) mirror([1, 0, 0]) rotate([0, 90, 0]) translate([-leg_x[1], 0, 0]) leg();
else leg_left();
