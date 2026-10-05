include <BOSL2/std.scad>

/* 
 * 3D Linear HTD Belt Clamp / Carriage Coupler
 * Creates a flat toothed profile to clamp an HTD 3M or 5M belt.
 */
module htd_linear_clamp(
    type = "5M",             // Belt type: "3M" or "5M"
    teeth = 6,               // Number of teeth to grip (6 to 8 is standard for strong grip)
    belt_width = 15,         // Width of the timing belt
    thickness = 4,           // Thickness of the solid material *under* the belt grooves
    padding = "auto",        // Flat space at the ends (defaults to half a pitch)
    flange_thickness = 1.5,  // Thickness of side retaining walls (set to 0 for no walls)
    flange_height = 2.0,     // How high the walls rise above the belt
    anchor = CENTER,         // BOSL2 anchor point
    spin = 0,                // BOSL2 spin rotation
    orient = UP              // BOSL2 orientation
) {
    // Validate input
    assert(type == "3M" || type == "5M", "Clamp type must be '3M' or '5M'");

    // --- HTD 3M / 5M Mathematics ---
    pitch = (type == "5M") ? 5.0 : 3.0;
    tooth_depth = (type == "5M") ? 2.06 : 1.22;
    groove_radius = (type == "5M") ? 1.49 : 1.05;

    // --- Block Dimensions ---
    pad = (padding == "auto") ? (pitch / 2) : padding;
    length = (teeth - 1) * pitch + 2 * pad;
    
    body_w = belt_width + (2 * flange_thickness);
    belt_seating_h = thickness + tooth_depth;
    total_h = belt_seating_h + flange_height;

    // Define object as a native BOSL2 attachable block
    attachable(anchor, spin, orient, size=[length, body_w, total_h]) {
        
        down(total_h / 2)
        diff("htd_linear_clamp") {
            // 1. ADDITIVE: The main solid block
            cuboid([length, body_w, total_h], anchor=BOTTOM, $fn=32);
            
            // 2. SUBTRACTIVE: Carve out the channels and teeth
            tag("htd_linear_clamp") {
                
                // Carve the central channel for the belt (leaving the flanges)
                if (flange_height > 0) {
                    // We drop the cutter by 0.01mm to prevent Z-fighting artifacts
                    up(belt_seating_h - 0.01)
                    cuboid([length + 0.2, belt_width, flange_height + 0.02], anchor=BOTTOM);
                }
                
                // Carve the horizontal teeth grooves
                // Center of the groove cylinder is placed exactly so the lowest point hits 'thickness'
                up(thickness + groove_radius) 
                xcopies(spacing=pitch, n=teeth)
                xrot(90)
                cyl(r=groove_radius, h=belt_width + 0.2, anchor=CENTER, $fn=32);
            }
        }
        
        // 3. ALLOW CHILDREN TO ATTACH
        children();
    }
}

// ==========================================
// EXAMPLE USAGE:
// ==========================================

// Example 1: Standard HTD 5M Clip for 15mm belt (Creates flanges automatically)
// htd_linear_clamp(type="5M", teeth=6, belt_width=15);

// Example 2: HTD 3M Profile without flanges (Useful if you want to subtract this from a larger carriage block)
// back(30)
// htd_linear_clamp(type="3M", teeth=8, belt_width=9, flange_thickness=0, flange_height=0);

// Example 3: BOSL2 Assembly - Creating a complete bolt-on carriage clamp
// We use BOSL2's attachment system to easily stick screw tabs onto the ends!
// fwd(35)
// diff("holes") {
//     // Generate the base clamp
//     htd_linear_clamp(type="5M", teeth=5, belt_width=15)
        
//         // Attach a tab to the LEFT side, then punch an M3 hole through it
//         attach(LEFT+BOTTOM, anchor=RIGHT+BOTTOM)
//         cuboid([12, 18, 4])
//             tag("holes") position(CENTER) cyl(d=3.2, h=10)
        
//         // Attach a tab to the RIGHT side, punch an M3 hole through it
//         attach(RIGHT+BOTTOM, anchor=LEFT+BOTTOM)
//         cuboid([12, 18, 4])
//             tag("holes") position(CENTER) cyl(d=3.2, h=10);
// }