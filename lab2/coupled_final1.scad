include <BOSL2/std.scad>
include <BOSL2/screws.scad>

$fn = $preview ? 8 : 128;

function m5stick_dim() = [25, 48, 13.5]; // Length, Width, Height of M5Stick
function m5stick_screw_hole() = 2;
function m5stick_screw_hole_offset() = [16, 9.4];
function m5stick_zrounding() = 3;

function neo550_od() = 35;
function neo_od() = 58;
function neo11_neo550_distance() = 2.38659;
function neo11_neo550_center_distance() = neo11_neo550_distance() + neo_od()/2 + neo550_od()/2;
function as5048p_screw_diameters() = 2.5; //larger (initially screm M2) bcs to attach a metal screwhole
function as5048p_screw_interval() = 12;
function odrive_v36_dim() = [50, 140.5];


//m5stick
module m5stickc_mount(
        m5_l        = m5stick_dim()[0],
        m5_w        = m5stick_dim()[1],
        m5_h        = m5stick_dim()[2],
        wall        = 2
    ) {
    pocket_h = m5_h / 3;
    box_h    = pocket_h + wall;

    diff() cuboid([m5_l + 2*wall, m5_w, box_h], anchor=BOT+FWD, rounding=1) {

        tag("remove") attach(TOP, TOP, inside=true) cuboid([m5_l, m5_w, pocket_h], anchor=BOTTOM, rounding=m5stick_zrounding(), edges="Z");

        tag("remove") fwd(m5_w/2 - m5stick_screw_hole_offset()[1]) xcopies(m5stick_screw_hole_offset()[0], n=2) screw_hole(str("M",m5stick_screw_hole()), l=box_h);
    }

}
//rotated and moved the position
//xrot(90) left(-neo550_od())  up(neo550_od()/2) m5stickc_mount();

//odrive-on-rev
module maxswerve_motor_plate(h=4, wall=4, spin=0) { //default values of the module parameters

    encoder_screw_d = as5048p_screw_diameters();
    encoder_screw_hole_interval = as5048p_screw_interval();

    egg_path = egg(neo11_neo550_distance()+neo_od()+neo550_od(),neo_od()/2,neo550_od()/2,neo11_neo550_distance()+neo_od()+neo550_od(), anchor="left");

    //defined custom anchors
    anchors = [
        named_anchor("right", [neo11_neo550_center_distance(),0,0], UP, 0), //starts at the top of the shape
        named_anchor("right_bottom", [neo11_neo550_center_distance(),0,-h/2], DOWN, 0), //starts at the bottom of the shape
        named_anchor("right_top", [neo11_neo550_center_distance(),0,h/2], UP, 0)
    ];

    //overall egg spage, linear extrude the egg shape and add screw holes for the encoder
    attachable(TOP, spin, UP, path=egg_path, l=h, anchors=anchors) {
        down(h/2) linear_extrude(h=h, center=false) diff() egg(neo11_neo550_distance()+neo_od()+neo550_od(),neo_od()/2,neo550_od()/2 ,neo11_neo550_distance()+neo_od()+neo550_od()+50, anchor="left") {
            tag("remove") attach("right") {
                xcopies(encoder_screw_hole_interval,2) circle(d=encoder_screw_d);
                circle(d=encoder_screw_d);
            }
            tag("remove") attach("left") circle(d=encoder_screw_d);

        }


        children();


    }


}

//one placement chain, reused by the mount and by its cutout so they cannot drift apart
module m5_place(wall=4) {
    yrot(-30) up(-m5stick_dim()[2]/3) left(m5stick_dim()[0]) back(-wall/2) children();
}

//the volume the M5Stick itself needs kept clear: the mount's pocket
module m5stickc_pocket(
        m5_l = m5stick_dim()[0],
        m5_w = m5stick_dim()[1],
        m5_h = m5stick_dim()[2],
        wall = 2,
        slop = 0.01
    ) {
    pocket_h = m5_h / 3;
    up(wall) cuboid([m5_l, m5_w, pocket_h + slop], anchor=BOT+FWD,
                    rounding=m5stick_zrounding(), edges="Z");
}

//tag names must NOT be the default "remove"/"keep": m5stickc_mount() runs its own
//diff() internally, and the default names collide with it and wipe out its pocket
diff("m5hole", "m5keep") maxswerve_motor_plate() {
    clearance = 0.2;
    wall = 4;
    motor_tube_h = 8;
    odrive_screw_tube_h = 20;

    //the circle tub at the bottom of the egg
    attach(TOP, TOP, inside=true) tube(id1=neo_od()+clearance, id2=neo_od(), od=neo_od()+wall, h=motor_tube_h+wall);

    //two sticking out sticks
    attach(TOP, BOT) back(11) xcopies(38.5, sp=0, n=2) diff() tube(id=4, od1=12, od2=4+wall, h=odrive_screw_tube_h+wall) {
        attach(TOP, TOP, inside=true) tag("remove") cyl(d=4, h=wall, chamfer=-1);
    }

    //adding m5stick - "m5keep" so the cutout below does not eat the mount itself
    tag("m5keep") attach (FRONT+RIGHT) m5_place(wall) m5stickc_mount();

    //adding hole into the egg shape, same placement chain as the mount above
    tag("m5hole") attach (FRONT+RIGHT) m5_place(wall) m5stickc_pocket();

    if ($preview) show_anchors();
}
