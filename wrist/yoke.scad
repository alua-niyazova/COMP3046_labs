// Yoke: Ø60 ring holding the cup bearings, with two hollow pitch stubs. Cable
// runs from the cup drum through windows in the ring, around an idler inside
// each stub, and out through the Ø28 stub bore.

include <wrist_params.scad>

orient_for_print = true;   // ring face on the bed; stubs need support

yoke_r      = 30;
yoke_h      = 37;
yoke_seat_r = b6807[1] / 2 + 0.09 + fit;
yoke_lip_r  = 22.8;
yoke_block_x = 28;          // outer x of the square block between ring and stub
stub_r      = b6807[0] / 2 - 0.05;
stub_bore_r = 13.96;
strip_w     = 10;           // ring strips left standing in the cable plane

module yoke_interior() {
    h = yoke_h / 2;
    rotate_extrude() polygon([
        [0, -h - 1], [yoke_lip_r, -h - 1], [yoke_lip_r, -16.5],
        [yoke_seat_r, -16.5], [yoke_seat_r, -10], [26.6, -4], [27, -3.6],
        [27, 3.6], [26.6, 4], [yoke_seat_r, 10], [yoke_seat_r, 16.5],
        [yoke_lip_r, 16.5], [yoke_lip_r, h + 1], [0, h + 1]]);
}

module yoke_stub_body() {
    // block bridging ring and stub
    translate([20, -18.5, -yoke_h / 2]) cube([yoke_block_x - 20, 37, yoke_h]);
    // stub: shoulder, retaining groove, shoulder, bearing seat
    revolve_x([
        [yoke_block_x - eps, 0], [yoke_block_x - eps, 18.5], [29, stub_r],
        [31, stub_r], [32, 18.48], [33, 18.48], [33, stub_r],
        [39.2, stub_r], [39.7, stub_r - 0.25], [40, 16], [40, 0]]);
}

module yoke_stub_cuts() {
    hz = cable_plane_h / 2;
    // bore through the stub with an entry chamfer
    revolve_x([[34, 0], [34, stub_bore_r], [38, stub_bore_r], [40 + eps, 16], [40 + eps, 0]]);
    // idler pocket and side slit in the cable plane
    translate([29.31, -3, -hz]) cube([34 - 29.31 + eps, 15, 2 * hz]);
    translate([29.31, -18.6, -hz]) cube([30.7 - 29.31, 18.6, 2 * hz]);
    // idler pin, blind from both sides of the pocket
    translate([yoke_idler[0], yoke_idler[1], 0])
        for (m = [0, 1]) mirror([0, 0, m])
            translate([0, 0, hz - eps]) cylinder(d = yoke_pin_d, h = 10.92 - hz + eps, $fn = 24);
}

module yoke() {
    h = yoke_h / 2;
    difference() {
        union() {
            rotate_extrude() polygon([[0, -h], [27.3, -h], [yoke_r, -15], [yoke_r, 15], [27.3, h], [0, h]]);
            for (m = [0, 1]) mirror([m, 0, 0]) yoke_stub_body();
        }
        yoke_interior();
        // cable windows: open the ring band everywhere except two strips
        difference() {
            cylinder(r = yoke_r + eps, h = cable_plane_h, center = true);
            cube([strip_w, 2 * yoke_r + 1, cable_plane_h + 1], center = true);
        }
        for (m = [0, 1]) mirror([m, 0, 0]) yoke_stub_cuts();
    }
}

if (orient_for_print) translate([0, 0, yoke_h / 2]) yoke();
else yoke();
