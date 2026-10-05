include <BOSL2/std.scad>
include <BOSL2/screws.scad>
include <n5065-mounts.scad>
include <htd-pulley.scad>
include <htd-linear-clamp.scad>

$fn = $preview ? 8 : 128;

carriage_dim = [20, 40, 10];
carriage_screw_hole_interval = [16, 15];

amt102_amt103_width = 29.2;

heatinsert_diameter = 3.8;
heatinsert_legth = 4;

lift_tube_clearance = 0.4;
lift_tube_od = 10;
lift_tube_length = 200;
rail_screw_diameter = 3;

mount_tube_clearance = 0.4;
mount_tube_od = 25;

mount_couple_screw_diameter = 3;
mount_gap = 2.4;
mount_wall_thickness = mount_couple_screw_diameter * 2;
mount_length = n5065_motor_length();

belt_length_required = 34*5 + mount_wall_thickness*2 + mount_tube_od*2 + lift_tube_length*2 + n5065_motor_diameter(); // 34 teeth * 5mm pitch for the 5M belt
echo("belt_length_required: ", belt_length_required);

hide("clamp") {

    tag("base") diff() cuboid([n5065_motor_diameter(), mount_length, mount_wall_thickness*2 + mount_tube_od], anchor=FWD+BOT, rounding=2, edges=[TOP+FWD, TOP+LEFT, TOP+RIGHT, BOT+BACK]) {

        tag("remove") attach(FWD, FWD, inside=true) {
            cuboid([mount_tube_od + mount_tube_clearance, mount_length*2, mount_tube_od + mount_tube_clearance]);
            cuboid([n5065_motor_diameter(), mount_length*2, mount_gap]);
        }
        tag("remove")
            grid_copies((n5065_motor_diameter() - mount_tube_od + mount_tube_clearance)/2 + mount_tube_od)
                screw_hole(str("M", mount_couple_screw_diameter), l=mount_wall_thickness*2 + mount_tube_od) {
                    attach(BOT, BOT, inside=true) cyl(d=heatinsert_diameter, h=heatinsert_legth, chamfer1=-0.6);
                }

        // homework answer
        align(BACK, TOP) cuboid([n5065_motor_diameter(), 6+6+carriage_dim[0]+1.5, (mount_wall_thickness*2 + mount_tube_od)/2], rounding=2, edges=[TOP+LEFT, TOP+RIGHT]) {
            right(lift_tube_od/2) attach(TOP, BOT) half_of(LEFT) rect_tube(l=40, size=6+carriage_dim[0]+1.5, isize=lift_tube_od+mount_tube_clearance) {
                tag("remove") attach(LEFT, TOP, inside=true) ycopies(20, n=2) #screw_hole(str("M", rail_screw_diameter), l=lift_tube_od) {
                    attach(TOP, TOP, inside=true) cyl(d=heatinsert_diameter, h=heatinsert_legth, chamfer2=-0.6);
                }
            }
        }
        
        

        align(BOT, FWD) cuboid([n5065_motor_diameter(), 6, 4]) {
            yflip() attach(BOT, RIGHT) n5065_front_mount(circle=false) {
                attach(TOP, BOT) zrot(25) arc_copies(d=amt102_amt103_width+6, n=2, sa=0, ea=360) cuboid(6, rounding=1, edges="Z") {
                    tag("remove") attach(TOP, TOP, inside=true) screw_hole("M3", l=12) {
                        attach(TOP, TOP, inside=true) cyl(d=heatinsert_diameter, h=heatinsert_legth, chamfer2=-0.6);
                    }
                }

                down(n5065_motor_length())
                   attach(BOT, TOP) htd_pulley(type="5M", teeth=34, belt_width=10, hub_h=0, flange_thickness=5) {
                       tag("remove") attach(TOP, BOT, inside=true) n5065_rear_bore();
                       tag("remove") attach(BOT, TOP, inside=true) n5065_rear_screws(l=10+5*2+1.5);
                    }
            }
        }
    }

    tag("clamp") diff() htd_linear_clamp(type="5M", teeth=8, belt_width=10, thickness=12, flange_thickness=10) {
        tag("remove") grid_copies(carriage_screw_hole_interval, n=2) screw_hole(str("M", rail_screw_diameter), l=carriage_dim[2]);

        attach(TOP, BOT, overlap=-10) cuboid([40, 30, 6]) {
            tag("remove") grid_copies(carriage_screw_hole_interval, n=2) screw_hole(str("M", rail_screw_diameter), l=carriage_dim[2]+80);
        }
    }
}