// HTD 5M pitch pulley. Slides onto the yoke's pitch shaft outside the left leg
// and bolts to the shaft end with 3x M3. Local axis = Z, z = 0 is the face
// towards the leg.

include <wrist_params.scad>

orient_for_print = true;   // end plate on the bed

pulley_bore_d = 2 * pitch_shaft_r + 0.3;
pulley_fl_over = 1.5;
pulley_hub_r  = pitch_shaft_r + 5;
pulley_rim_t  = 4;      // rim under the tooth roots
pulley_web_t  = 4;      // web on the end plate side

module pitch_pulley() {
    fr = htd_ro(pitch_teeth) + pulley_fl_over;
    rim_in = htd_root(pitch_teeth) - pulley_rim_t;
    // lightening holes in the web, if there is room
    hole_d = rim_in - pulley_hub_r - 6;
    hole_r = (rim_in + pulley_hub_r) / 2;
    hole_n = min(6, floor(2 * PI * hole_r / (hole_d + 5)));
    difference() {
        union() {
            cylinder(r = fr, h = pitch_fl_t);
            translate([0, 0, pitch_fl_t]) htd_teeth(pitch_teeth, pitch_band_h);
            translate([0, 0, pitch_fl_t + pitch_band_h]) cylinder(r = fr, h = pitch_fl_t);
            translate([0, 0, pitch_pulley_len - eps]) cylinder(r = pulley_hub_r, h = pitch_plate_t + eps);
        }
        translate([0, 0, -1]) cylinder(d = pulley_bore_d, h = pitch_pulley_len + 1);
        // hollow between hub and rim, open towards the leg
        if (rim_in > pulley_hub_r + 2) translate([0, 0, -1]) difference() {
            cylinder(r = rim_in, h = pitch_pulley_len - pulley_web_t + 1);
            cylinder(r = pulley_hub_r, h = pitch_pulley_len + 2);
        }
        if (hole_d >= 6) for (i = [0 : hole_n - 1]) rotate([0, 0, i * 360 / hole_n + 30])
            translate([hole_r, 0, -1]) cylinder(d = hole_d, h = pitch_pulley_len + 2);
        translate([0, 0, pitch_pulley_len - 1]) cylinder(d = 8, h = pitch_plate_t + 2);
        for (i = [0 : 2]) rotate([0, 0, i * 120]) translate([pitch_screw_pcd / 2, 0, pitch_pulley_len - 1])
            cylinder(d = 3.4, h = pitch_plate_t + 2, $fn = 20);
    }
}

if (orient_for_print) translate([0, 0, pitch_pulley_len + pitch_plate_t]) mirror([0, 0, 1]) pitch_pulley();
else pitch_pulley();
