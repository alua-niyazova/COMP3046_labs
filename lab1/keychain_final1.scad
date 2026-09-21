include <BOSL2/std.scad>
include <BOSL2/screws.scad>

$fn = $preview ? 8 : 128;

student_name = "Alua";   // <-- change this parameter
key_width    = 20;
key_height   = 20;
key_thick    = 4;
top_wing_r = 10;
bottom_wing_r = 8;
hole_dia     = 4.0;  // clearance for keyring


diff()
// cuboid([10, 8, 1]) {

//     attach (TOP, BACK, overlap = 0.5){
//     teardrop2d (d=12, h=4, spin = 50, bot_corner = 3);
//     }
    
//     attach (TOP, BACK, overlap = 0.5){
//     teardrop2d (d=12, h=4, spin = -50, bot_corner = 3);
//     }
    
//     attach (TOP, BACK, overlap = 0.5){
//     teardrop2d (d=10, h=4, spin = 135, bot_corner = 2);
//     }
    
//     attach (TOP, BACK, overlap = 0.5){
//     teardrop2d (d=10, h=4, spin = -135, bot_corner = 2);
//     }

// }

cuboid([18, 18, 4], rounding = 2) {
//top right
    attach (TOP, BACK, overlap = 0.0){
        up (-4) left(top_wing_r+0.5) back(top_wing_r-1.5) teardrop(r1=top_wing_r, r2=top_wing_r-1.5, h=key_thick/2, spin = 50, bot_corner = 3, anchor=BOTTOM);
    }
    
    attach (TOP, BACK, overlap = 0.0){
        up (-2) left(top_wing_r+0.5) back(top_wing_r-1.5) teardrop(r1=top_wing_r-1.5, r2=top_wing_r, h=2, spin = 50, bot_corner = 3, anchor=BOTTOM);
    }
   
//top left   
    attach (TOP, BACK, overlap = 0.0){
        up (-4) left(-top_wing_r-0.5) back(bottom_wing_r+0.5) teardrop(r1=top_wing_r, r2=top_wing_r-1.5, h=2, spin = -50, bot_corner = 3, anchor=BOTTOM);
    }
    
    attach (TOP, BACK, overlap = 0.0){
        up (-2) left(-top_wing_r-0.5) back(bottom_wing_r+0.5) teardrop(r1=top_wing_r-1.5, r2=top_wing_r, h=2, spin = -50, bot_corner = 3, anchor=BOTTOM);
    }
    
//bottom right    
    
    attach (TOP, BACK, overlap = 0.0){
        up (-4) left(bottom_wing_r) back(-bottom_wing_r+1.5) teardrop(r1=bottom_wing_r, r2=bottom_wing_r-1, h=2, spin = 135, bot_corner = 2, anchor=BOTTOM);
    }
    
    attach (TOP, BACK, overlap = 0.0){
        up (-2) left(bottom_wing_r) back(-bottom_wing_r+1.5) teardrop(r1=bottom_wing_r-1, r2=bottom_wing_r, h=2, spin = 135, bot_corner = 2, anchor=BOTTOM);
    }
    
//bottom left
    
    attach (TOP, BACK, overlap = 0.0){
        up (-4) left(-bottom_wing_r) back(-bottom_wing_r+1.5) teardrop(r1=bottom_wing_r, r2=bottom_wing_r-1, h=2, spin = -135, bot_corner = 2, anchor=BOTTOM);
    }
    
    attach (TOP, BACK, overlap = 0.0){
        up (-2) left(-bottom_wing_r) back(-bottom_wing_r+1.5) teardrop(r1=bottom_wing_r-1, r2=bottom_wing_r, h=2, spin = -135, bot_corner = 2, anchor=BOTTOM);
    }
    
//vyimka    
    
    attach (TOP, overlap=-0.1, rounding = -1){
        tag("remove") cuboid([2, 25, 1], anchor = TOP, rounding=-1, edges = [TOP+LEFT, TOP+RIGHT]);
    }
    
//name text     
    attach(TOP, overlap = 1){
    left(-top_wing_r+3.5)
    back(0.5)
    tag ("remove")
    linear_extrude(height=1.5)
    #text(student_name, size=7, halign="center", valign="center",
                 font="Liberation Sans:style=Bold", spin = -90);
    } 
   
//ring hole
    attach (TOP){
    up(-key_thick-0.1)
    left (top_wing_r+4)
    back(top_wing_r+2)
    tag ("remove")
    cyl(d=hole_dia, h=key_thick+0.2, anchor=BOTTOM, rounding = -1);
    }
}