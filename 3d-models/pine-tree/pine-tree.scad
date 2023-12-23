//# SPDX-FileCopyrightText: 2023 Gordy Keene
//# SPDX-License-Identifier: MIT

//# Pine Tree stand for RGB LED rings

// ===== INFORMATION ===== //
/*

For faster rendering:
  * Update to a recent OpenSCAD evelopment build
  * Enable fast-csg: Edit > Preferences > Features > fast-csg

The default measurements are for a P2.5, "HUB75," 64x32 RGB LED Matrix, such as:
  * https://www.adafruit.com/product/5036
  * https://www.aliexpress.us/w/wholesale-P2.5-HUB75-64x32-RGB-LED-Matrix.html
  * https://www.aliexpress.us/item/2255799816372142.html
  * https://www.amazon.com/s?k=P2.5+HUB75+64x32+RGB+LED+Matrix
The prices vary widely, so shop around, just be sure they are P2.5 (pitch) and 64x32 pixels (measuering 160mm wide by 80mm tall).
  
You can drive them however you want. I have had great experiances driving eight panels with this controller. I'm told it can do up to 12.
  * https://www.adafruit.com/product/5778
  
*/

// ===== PARAMETERS ===== //

render_options = ["Leaves (for print)", "Trunk (for print)", "Leaves stacked", "Leaves and trunk quartered", "Leaves and trunk sliver", "Leaf rings only"];

/* [Viewing Options] */
// Select view to render
view = "Leaves (for print)"; // ["Leaves (for print)", "Trunk (for print)", "Leaves stacked", "Leaves and trunk quartered", "Leaves and trunk sliver", "Leaf rings only"]

/* [LED Ring Measurements] */
// Width of the LED ring, x/y-plane (outer-inner diameter)
ring_width = 9;
// Gap between LED ring and leaf, x/y-plane
ring_inner_offset = 2;
// Height of the LED ring, z-axis
ring_height = 1.6;

/* [Cable Raceway Measurements] */
// Horizontal cable raceway height, z-axis
cable_raceway_height = 2;
// Width of the horizontal cable raceway, x-axis
cable_raceway_width = 20;
// Min vertical raceway radius, x/y-plane
cable_raceway_radius = 3;

/* [Pine Tree Settings] */
// Minimum radius of the trunk
minimum_trunk_radius = 3;
// Minimum wall thickness
minimum_wall_thickness = 1.2;
// Overlap between each trunk layer
trunk_layer_overlap = 1.6;

/* [Tweaks and adjustments] */
$fa = 4.5;
$fs = 0.25;
// Added to objects when used as a void
slop = 0.01;
// Nozzle diameter
nozzle_diameter = 0.4;

// This is a hack to ensure the Customizer ignores the rest of the values in this file.
module end_customizer() {}

// I really wish I could have included these in the Customizer, but it's not possible.
// The first "ring" is not a ring, rather it's the trunk of the tree.
// Per the documentation, the ring_diameters are: 120, 96, 72, 48, 27
// ring_radii = [minimum_trunk_radius, 13.5, 24, 36, 48, 60, 60];
ring_radii = [60, 60, 48, 36, 24, 13.5, minimum_trunk_radius];

// Calulated values
leaf_outer_edge_height = cable_raceway_height + nozzle_diameter;

// Colors
color_leaves = "Green";
color_trunk = "#362312";
color_raceway = "FireBrick";

// ===== IMPLEMENTATION ===== //

main();

module main() {
  if (render_options[0] == view) leaves_for_print();
  if (render_options[1] == view) trunk_for_print();
  if (render_options[2] == view) leaves_stacked();
  if (render_options[3] == view) leaves_and_trunk_quartered();
  if (render_options[4] == view) leaves_and_trunk_sliver();
  if (render_options[5] == view) leaves_rings_only();
}

module leaves_for_print() {
  spacer = 3;
  center_r = ring_radii[0] + spacer;

  leaf_at(0);

  rotate(a=[0,0,0]) 
    translate([center_r + ring_radii[1], 0, 0])
      leaf_at(1);

  rotate(a=[0,0,56]) 
    translate([center_r + ring_radii[2], 0, 0])
      leaf_at(2);

  rotate(a=[0, 0, 105]) 
    translate([center_r + ring_radii[3], 0, 0])
      leaf_at(3);

  rotate(a=[0, 0, 146]) 
    translate([center_r + ring_radii[4], 0, 0])
      leaf_at(4);

  rotate(a=[0,0,175]) 
    translate([center_r + ring_radii[5], 0, 0])
      leaf_at(5);
}

module trunk_for_print() {
  trunk_at(0);
  translate([0, 0, calc_layer_h_at(0)]) {
    trunk_at(1);
    translate([0, 0, calc_layer_h_at(1)]) {
      trunk_at(2);
      translate([0, 0, calc_layer_h_at(2)]) {
        trunk_at(3);
        translate([0, 0, calc_layer_h_at(3)]) {
          trunk_at(4);
          // Printing the top layer never works out well, guess I'll just glue it on
          translate([0, 0, calc_layer_h_at(4)]) {
            trunk_at(5);
          }
        }
      }
    }
  }
}

module leaves_stacked() {
  leaf_at(0);
  translate([0, 0, calc_layer_h_at(0)]) {
    leaf_at(1);
    translate([0, 0, calc_layer_h_at(1)]) {
      leaf_at(2);
      translate([0, 0, calc_layer_h_at(2)]) {
        leaf_at(3);
        translate([0, 0, calc_layer_h_at(3)]) {
          leaf_at(4);
          translate([0, 0, calc_layer_h_at(4)]) {
            leaf_at(5);
          }
        }
      }
    }
  }
}

module leaves_and_trunk_quartered() {
  k = 100; // Some value larger than the objects in most dimensions
  intersection() {
    color("gray", alpha=0.05)
      translate([-k, -k, -slop]) 
        cube([k + 1, k + 1, 2 * k]);
    leaves_stacked();
  }
  intersection() {
    color("gray", alpha=0.05)
      translate([-k -1, -1, -slop])
        cube([k, k, 2 * k]);
    trunk_for_print();
  }
}

module leaves_and_trunk_sliver() {
  k = 100; // Some value larger than the objects in most dimensions
  intersection()
  {
    color("gray", alpha=0.05)
      translate([-1, -k, -slop])
        cube([2, 2 * k, 2 * k]);
    union() {
      trunk_for_print();
      leaves_stacked();
    }
  }
}

module leaves_rings_only() {
  k = 200; // Some value larger than the objects in most dimensions
  intersection()
  {
    color("gray", alpha=0.05)
      translate([-k, -k, -slop])
        cube([2 * k, 2 * k, 2 * minimum_wall_thickness]);
    leaves_for_print();
  }
}

// ===== LEAF RINGS ===== //

module leaf_at(layer_index) {
  layer_h = calc_layer_h_at(layer_index);
  lower_r = calc_outer_r_at(layer_index);
  upper_r = calc_outer_r_at(layer_index + 1);
  net_upper_r = calc_net_upper_r_at(layer_index);
  r_diff = calc_r_diff_at(layer_index);
  lower_trunk_r = calc_net_inner_r_at(layer_index);

  echo("leaf. layer_h: ", layer_h, "upper_r: ", upper_r, ", lower_r: ", lower_r);
  echo("leaf. net_upper_r: ", net_upper_r, ", r_diff: ", r_diff);

  difference() 
  {
    color(color_leaves) union() {
      cylinder(h = layer_h, r = net_upper_r);
      cylinder(h = leaf_outer_edge_height + r_diff, r = lower_r);
    }

    // Carve the swoopy bit
    color(color_leaves, alpha=0.6) {
      translate([0, 0, leaf_outer_edge_height + r_diff]) {
        donut(r1 = lower_r + r_diff, r2 = r_diff);
      }
    }

    // Carve the vertical trunk cavity
    color(color_leaves, alpha=0.4) {
      translate([0, 0, -slop]) {
        cylinder(h = layer_h + 2 * slop, r = lower_trunk_r + slop);
      }
    }

    // Carve the horizontal cable raceway
    color(color_raceway, alpha=0.4) {
      cable_raceway(lower_r);
    }
  }
}

// ===== TRUNK RINGS ===== //

module trunk_at(layer_index) {
  layer_h = calc_layer_h_at(layer_index);
  lower_r = calc_outer_r_at(layer_index);
  upper_r = calc_outer_r_at(layer_index + 1);
  net_upper_r = calc_net_upper_r_at(layer_index);
  r_diff = calc_r_diff_at(layer_index);
  lower_trunk_r = calc_net_inner_r_at(layer_index);
  upper_trunk_r = calc_net_inner_r_at(layer_index + 1);

  r1 = max(minimum_trunk_radius, lower_trunk_r - nozzle_diameter / 2);
  r2 = max(minimum_trunk_radius, lower_trunk_r - nozzle_diameter);

  difference() 
  {
    color(color_trunk) {
      cylinder(h = layer_h, r1 = lower_trunk_r - nozzle_diameter / 2, r2 = lower_trunk_r - nozzle_diameter);
    }

    // Carve the vertical trunk cavity
    color(color_trunk, alpha=0.4)
    translate([0, 0, -slop]) {
      cylinder(h = layer_h + 2 * slop, r1 = lower_trunk_r - trunk_layer_overlap - nozzle_diameter, r2 = upper_trunk_r - trunk_layer_overlap - nozzle_diameter);
    }

    // Carve the horizontal cable raceway
    cable_raceway(lower_r); // net_lower_r);
    translate([0, 0, layer_h])
      rotate(a=[0,180,0])
        cable_raceway(lower_r); // net_lower_r);

    // Carve a vertical cable raceway
    color(color_raceway, alpha=0.4)
    translate([-cable_raceway_width / 2, -slop, -slop]) {
      cube([cable_raceway_width, lower_trunk_r, layer_h + 2 * slop]);
    }

  }
}

// ===== UTILITIES ===== //

/*
        (B)__  (H)
          |   |
          |   |
         /    |
       /      |
    _/        |
   |__________|
  (A)        (C)

*/

function next_layer_index_at(layer_index) =
  min(layer_index + 1, len(ring_radii) - 1);

// (H)
function calc_layer_h_at(layer_index) =
  leaf_outer_edge_height + ring_radii[layer_index] - max(minimum_trunk_radius, ring_radii[next_layer_index_at(layer_index)] - ring_width - ring_inner_offset) + ring_height;

// (A)
function calc_outer_r_at(layer_index) =
  ring_radii[layer_index] + minimum_wall_thickness;

// (B)
function calc_net_upper_r_at(layer_index) =
  max(minimum_wall_thickness + minimum_trunk_radius, ring_radii[next_layer_index_at(layer_index)] - ring_width - ring_inner_offset);

// (C)
function calc_net_inner_r_at(layer_index) =
  max(minimum_trunk_radius, calc_outer_r_at(layer_index) - calc_layer_h_at(layer_index) + minimum_wall_thickness);

// (A) - (B)
function calc_r_diff_at(layer_index) =
  calc_outer_r_at(layer_index) - calc_net_upper_r_at(layer_index);

module cable_raceway(lower_r)
  color(color_raceway, alpha=0.4)
    rotate(a=[0, 0, 90])
      translate([0, 0, -slop])
        intersection() {
          union() {
            translate([0, 0, cable_raceway_height / 2])
              rotate(a=[0, 90, 0]) 
                scale([cable_raceway_height, cable_raceway_width])
                  cylinder(lower_r + 2 * slop, d = 1);
            translate([0, -cable_raceway_width / 2, 0])
              cube([lower_r, cable_raceway_width, cable_raceway_height / 2]);
          }
          cylinder(h = cable_raceway_height * 2, r = lower_r - minimum_wall_thickness);
        }

// ===== GENERIC UTILITIES ===== //

module donut(r1, r2) {
  rotate_extrude(angle = 360)
      translate([r1 - r2, 0])
          circle(r = r2);
}

module truncatedPyramid2(size, delta)
  truncatedPyramid(size[0], size[1], delta[0], delta[1], delta[2]);
module truncatedPyramid(x, y, dx, dy, dz) {
  CubePoints = [
    [ 0,  0,  0 ],  //0
    [ x,  0,  0 ],  //1
    [ x,  y,  0 ],  //2
    [ 0,  y,  0 ],  //3
    [ 0 + dx,  0 + dy,  dz ],  //4
    [ x - dx,  0 + dy,  dz ],  //5
    [ x - dx,  y - dy,  dz ],  //6
    [ 0 + dx,  y - dy,  dz ]]; //7
    
  CubeFaces = [
    [0,1,2,3],  // bottom
    [4,5,1,0],  // front
    [7,6,5,4],  // top
    [5,6,2,1],  // right
    [6,7,3,2],  // back
    [7,4,0,3]]; // left
    
  polyhedron( CubePoints, CubeFaces );
}

module embiggen() {
  hull() {
    translate([-slop, -slop, -slop]) children();
    translate([slop, slop, slop]) children();
  }
}
