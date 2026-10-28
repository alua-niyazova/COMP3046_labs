// HTD-5M closed belt, 800 mm (160T), 6 mm wide — roll belt for the wrist (roll_belt_w in wrist_params.scad).
use <../lab3/openscad-timing-belt-generator/scad-parametric-timing-belt-generator/timing_belt_generator.scad>
$fa = 2;
belting("folded_loop", "HTD_5mm", tooth_count=160, belting_width=6, printer="Bambu_A1_mini");
