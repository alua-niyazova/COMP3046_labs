include <BOSL2/std.scad>

/* 
 * 3D HTD Pulley Component (Supports 3M and 5M profiles)
 * Extends BOSL2 using attachable() and nested diff() logic.
 */
module htd_pulley(
    type = "3M",             // Belt type: "3M" or "5M"
    teeth = 20,              // Number of teeth
    belt_width = 10,         // Width of the timing belt (9mm or 15mm are common for HTD)
    bore_d = 5,              // Shaft diameter (e.g., 5mm for NEMA 17, 8mm for NEMA 23)
    d_flat = 4.5,            // Shaft flat distance. Set equal to bore_d for round shafts.
    hub_d = 18,              // Outer diameter of the mounting hub
    hub_h = 7,               // Height of the mounting hub (0 to disable)
    flange_thickness = 1,    // Thickness of the top and bottom retaining walls
    flange_overhang = 1.5,   // How far the flanges extend past the teeth
    set_screw_d = 3.2,       // Hole for set screw (3.2mm taps to M3, 4.2mm taps to M4)
    anchor = CENTER,         // BOSL2 anchor point
    spin = 0,                // BOSL2 spin rotation
    orient = UP              // BOSL2 orientation
) {
    // Validate input
    assert(type == "3M" || type == "5M", "Pulley type must be '3M' or '5M'");

    // --- HTD 3M / 5M Mathematics ---
    pitch = (type == "5M") ? 5.0 : 3.0;
    
    // Pitch Line Differential (Distance from inner belt wires to outer pulley edge)
    pld = (type == "5M") ? 0.5715 : 0.381; 
    
    // Tooth profile dimensions
    tooth_depth = (type == "5M") ? 2.06 : 1.22;
    groove_radius = (type == "5M") ? 1.49 : 1.05;

    // Calculate core pulley radii
    pitch_radius = (teeth * pitch) / (2 * PI);
    outer_radius = pitch_radius - pld; 
    
    // Calculate the distance from center to place the subtractive groove cylinders
    groove_offset = outer_radius - tooth_depth + groove_radius;
    
    // --- Body Dimensions ---
    flange_radius = outer_radius + flange_overhang;
    pulley_h = belt_width + 1.5; // Added 1.5mm tolerance for the belt
    total_h = flange_thickness * 2 + pulley_h + hub_h;
    
    // Dynamic facet count to keep curves smooth for 3D printing
    fn_val = max(36, teeth * 4);

    // Define object as a native BOSL2 cylindrical attachable
    attachable(anchor, spin, orient, r=flange_radius, l=total_h) {
        
        down(total_h / 2)
        // Main subtractive block
        diff("remove") {
            
            // --- 1. ADDITIVE GEOMETRY ---
            union() {
                // Bottom Flange
                cyl(r=flange_radius, h=flange_thickness, anchor=BOTTOM, $fn=fn_val);
                
                // Toothed Belt Path (Nested diff to carve teeth)
                up(flange_thickness)
                diff("grooves") {
                    cyl(r=outer_radius, h=pulley_h, anchor=BOTTOM, $fn=fn_val);
                    
                    tag("grooves")
                    zrot_copies(n=teeth)
                    right(groove_offset)
                    down(0.01) // Z-padding to prevent Z-fighting
                    cyl(r=groove_radius, h=pulley_h + 0.02, anchor=BOTTOM, $fn=16);
                }
                
                // Top Flange
                up(flange_thickness + pulley_h)
                cyl(r=flange_radius, h=flange_thickness, anchor=BOTTOM, $fn=fn_val);
                
                // Hub Extension
                if (hub_h > 0) {
                    up(flange_thickness * 2 + pulley_h)
                    cyl(d=hub_d, h=hub_h, anchor=BOTTOM, $fn=fn_val);
                }
            }
            
            // --- 2. SUBTRACTIVE GEOMETRY (Tagged "remove") ---
            tag("remove") {
                
                // Shaft Bore
                diff("flat") {
                    down(0.1)
                    cyl(d=bore_d, h=total_h + 0.2, anchor=BOTTOM);
                    
                    // Creates the D-flat
                    if (d_flat < bore_d) {
                        tag("flat")
                        back(d_flat - bore_d/2)
                        down(0.1)
                        cuboid([bore_d + 2, bore_d, total_h + 0.2], anchor=FRONT);
                    }
                }

                // Set Screw Hole (Aims from +Y towards center, striking the D-flat)
                if (hub_h > 0 && set_screw_d > 0) {
                    up(flange_thickness * 2 + pulley_h + hub_h/2)
                    back(hub_d/2)
                    xrot(90)
                    cyl(d=set_screw_d, h=hub_d/2 + 2, anchor=BOTTOM);
                }
            }
        }
        
        // --- 3. ALLOW CHILDREN TO ATTACH ---
        children();
    }
}