// HTD-5M closed belt, 445 mm (89T), 10 mm wide — matches elbow/pulleys.scad (23T motor, 50T shaft).
use <../lab3/openscad-timing-belt-generator/scad-parametric-timing-belt-generator/timing_belt_generator.scad>
$fa = 2;
belting("folded_loop", "HTD_5mm", tooth_count=89, belting_width=10, printer="Bambu_A1_mini");
