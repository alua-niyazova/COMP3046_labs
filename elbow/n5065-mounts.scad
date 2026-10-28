include <BOSL2/std.scad>
include <BOSL2/screws.scad>

function n5065_motor_diameter() = 50.4;
function n5065_motor_length() = 58.5;
function n5065_rear_bore_diameter() = 14.05;

module n5065_front_screws(thickness=6) {
    screw_hole_distance = 30;
    screw_hole_diameter = 4;

    attachable(r=[n5065_motor_diameter()/2,n5065_motor_diameter()/2], l=thickness, anchor=CENTER) {
        union() {
            cyl(d=9, h=thickness, anchor=CENTER);
            for (i = [0 : 3]) {
                zrot(i*90) fwd(screw_hole_distance/2) screw_hole(str("M", screw_hole_diameter), head="flat", l=thickness);
            }
        }
        children();
    }
}

module n5065_front_bricks(thickness=6) {
    num_pins = 6;
    pin_offset = 15;
    pin_diameter = 4.9;

    attachable(r=[n5065_motor_diameter()/2,n5065_motor_diameter()/2], l=thickness, anchor=CENTER) {
        intersect("n5065_front_bricks") {
            tag("n5065_front_bricks") cyl(d=n5065_motor_diameter(), h=thickness, anchor=CENTER);
            union() {
                for (i = [0 : num_pins - 1]) hull() {
                    zrot(45*i) fwd(pin_offset) cyl(h=thickness, d=pin_diameter);
                    zrot(45*i) fwd(n5065_motor_diameter()/2) cyl(h=thickness, d=pin_diameter);
                }
            }
        }
        children();
    }
}

module n5065_front_mount(thickness=6, inside_thickness=6, circle=true, anchor=CENTER) {
    num_pins = 6;
    pin_offset = 15;
    pin_diameter = 4.9;

    if (circle) {
         attachable(r=[n5065_motor_diameter()/2,n5065_motor_diameter()/2], l=thickness, anchor=anchor) {
            diff("n5065_front") cyl(d=n5065_motor_diameter(), h=thickness, anchor=CENTER) {
                // inside brick array
                attach(BOT, TOP) n5065_front_bricks(thickness=inside_thickness);

                // screw holes
                tag("n5065_front") zrot(-45/2) n5065_front_screws(thickness=thickness);
            }

            children();
        }
    } else {
        attachable(size=[n5065_motor_diameter(),n5065_motor_diameter(), thickness], anchor=anchor) {
            diff("n5065_front") cuboid([n5065_motor_diameter(), n5065_motor_diameter(), thickness], anchor=CENTER) {
                // inside brick array
                attach(BOT, TOP) n5065_front_bricks(thickness=inside_thickness);

                // screw holes
                tag("n5065_front") zrot(-45/2) n5065_front_screws(thickness=thickness);
            }

            children();
        }
    }
}

module n5065_rear_screws(l=6) {
    attachable(r=[n5065_motor_diameter()/2,n5065_motor_diameter()/2], l=l, anchor=CENTER) {
        union() {
            for (rot=[0:3]) rot(rot*90) move([7,7,0]) {
                screw_hole("M3",head="flat", l=l);
            }
        }
        children();
    }
}

module n5065_rear_bricks(thickness=6) {
    attachable(r=[n5065_motor_diameter()/2,n5065_motor_diameter()/2], l=thickness, anchor=CENTER) {
        intersect("n5065_rear_bricks") {
            tag("n5065_rear_bricks") cyl(d=n5065_motor_diameter(), h=thickness, anchor=CENTER);
            union() {
                for (rot=[0:3]) {
                    hull() rot(rot*90) fwd(9+4) cyl(h=thickness, d=8.05) {
                        fwd(8+4) cyl(h=thickness, d=8.05);
                    }

                    hull() rot(45+rot*90) fwd(13.5+4) cyl(h=thickness, d=8.05) {
                        fwd(3.5+4) cyl(h=thickness, d=8.05);
                    }
                }
            }
        }
        children();
    }
}

module n5065_rear_bore() {
    attachable(r=[n5065_motor_diameter()/2,n5065_motor_diameter()/2], l=2, anchor=CENTER) {
        cyl(d=14.05, h=2, rounding1=-1);
        children();
    }
}

module n5065_rear_mount(thickness=6, inside_thickness=6, circle=true, anchor=CENTER) {
    assert(inside_thickness <= 6, "inside thickness must be less than or equal to 6");

    if (circle) {
        attachable(r=[n5065_motor_diameter()/2,n5065_motor_diameter()/2], l=thickness, anchor=anchor) {
            down(thickness) xrot(180) diff("n5065_rear") cyl(d=n5065_motor_diameter(), h=thickness, anchor=TOP) {

                // center bore
                tag("n5065_rear") attach(BOT, BOT, inside=true) n5065_rear_bore();

                // screw holes
                tag("n5065_rear") attach(TOP, TOP, inside=true) n5065_rear_screws(l=thickness);

                // motor output brick array
                attach(BOT, TOP) n5065_rear_bricks(thickness=inside_thickness);
            }

            children();
        }
    } else {
        attachable(size=[n5065_motor_diameter(), n5065_motor_diameter(), thickness], anchor=anchor) {
            down(thickness) xrot(180) diff("n5065_rear") cuboid([n5065_motor_diameter(), n5065_motor_diameter(), thickness], anchor=TOP) {

                // center bore
                tag("n5065_rear") attach(BOT, BOT, inside=true) n5065_rear_bore();

                // screw holes
                tag("n5065_rear") attach(TOP, TOP, inside=true) n5065_rear_screws(l=thickness);

                // motor output brick array
                attach(BOT, TOP) n5065_rear_bricks(thickness=inside_thickness);
            }

            children();
        }
    }
}

module n5065_mounts(thickness=6, inside_thickness=6, anchor=CENTER) {
    parts = [
        define_part("front", attach_geom(r=n5065_motor_diameter()/2,h=thickness+5), T=up(n5065_motor_length()/2+1)),
        define_part("rear", attach_geom(r=n5065_motor_diameter()/2,h=thickness+5), T=down(n5065_motor_length()/2+1))
    ];
    attachable(r=[n5065_motor_diameter()/2,n5065_motor_diameter()/2], l=n5065_motor_length() + thickness*2, parts=parts, anchor=anchor) {
        union() {
            up(n5065_motor_length()/2) n5065_front_mount(thickness=thickness, inside_thickness=inside_thickness);
            down(n5065_motor_length()/2) n5065_rear_mount(thickness=thickness, inside_thickness=inside_thickness);
        }
        children();
    }
}