//# SPDX-FileCopyrightText: 2023 Gordy Keene
//# SPDX-License-Identifier: MIT

//# Pine Tree stand for RGB LED rings

// ===== INFORMATION ===== //
/*

For faster rendering:
  * Update to a recent OpenSCAD evelopment build
  * Enable fast-csg: Edit > Preferences > Features > fast-csg

For understanding the Customizer:
  * https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Customizer

*/

// ===== PARAMETERS ===== //

render_options = ["Leaves (for print)", "Trunk (for print)", "Leaves stacked", "Leaves and trunk quartered", "Leaves and trunk sliver", "Leaf rings only"];

/* [Viewing Options] */
// Select view to render
view = "Leaves (for print)"; // ["Leaves (for print)", "Trunk (for print)", "Leaves stacked", "Leaves and trunk quartered", "Leaves and trunk sliver", "Leaf rings only"]
// First layer to render (0 is the bottom layer)
first_layer = 0;
// Last layer to render (-1 calculates top layer)
last_layer = -1;

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
// Minimum fragment angle
$fa = 4.5;
// Minimum fragment size
$fs = 0.25;
// Added to objects when used as a void
slop = 0.01;
// Used to adjust gaps between objects
nozzle_diameter = 0.4;

/* [Hidden] */

// I really wish I could have included these in the Customizer, but it's not possible.
// Per the documentation, the ring_diameters are: 120, 96, 72, 48, 27
// The radii must be in decending order
// The first value is the "base" of the tree.
// Setting the base less then the first layer is not well supported.
ring_radii = [60, 60, 48, 36, 24, 13.5];

// Having that last value in the ring_radii does compliclate the logic a bit, so we subtract two.
ring_radii_last_index = len(ring_radii) - 1;

// Constants and Calulated values
large_dimension = 4 * max(ring_radii);  // Some value larger than the objects in most dimensions
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

// This depends on the ring_radii being in descending order
module leaves_for_print() {
  extra_r = 4;
  first_layer_index = calc_first_layer_index();
  last_layer_index = calc_last_layer_index();
  center_r = calc_outer_r_at(first_layer_index);

  for (index = [first_layer_index : last_layer_index]) {
    if (index == first_layer_index) {
      leaf_at(first_layer_index);
    } else if (index == 1 + first_layer_index) {
      translate([extra_r + center_r + calc_outer_r_at(index), 0, 0])
        leaf_at(index);
    } else {
      angle = SumTheAnglesBetween(center_r, first_layer_index + 1, index);
      rotate(a=[0, 0, angle])
        translate([extra_r + center_r + calc_outer_r_at(index), 0, 0])
          rotate(a=[0, 0, -angle])
            leaf_at(index);
    }
  }
}

function SumTheAnglesBetween(center_r, from_layer_index, to_layer_index) =
  from_layer_index >= to_layer_index ? 0
    : law_of_cosines_for_radii(center_r, calc_outer_r_at(to_layer_index - 1), calc_outer_r_at(to_layer_index))
      + SumTheAnglesBetween(center_r, from_layer_index, to_layer_index - 1);

module trunk_for_print() 
  trunk_for_print_recurse(calc_first_layer_index());

module trunk_for_print_recurse(layer_index) {
  if (layer_index <= calc_last_layer_index()) {
    trunk_at(layer_index);
    translate([0, 0, calc_layer_h_at(layer_index)]) {
      trunk_for_print_recurse(layer_index + 1);
    }
  }
}

module leaves_stacked()
  leaves_stacked_recurse(calc_first_layer_index());

module leaves_stacked_recurse(layer_index) {
  if (layer_index <= calc_last_layer_index()) {
    leaf_at(layer_index);
    translate([0, 0, calc_layer_h_at(layer_index)]) {
      leaves_stacked_recurse(layer_index + 1);
    }
  }
}

// Generates two quarters to inspect leaf and trunk fitment
module leaves_and_trunk_quartered() {
  intersection() {
    color("gray", alpha = 0.05)
      translate([-large_dimension, -large_dimension, -slop]) 
        cube([large_dimension + 1, large_dimension + 1, 2 * large_dimension]);
    leaves_stacked();
  }
  intersection() {
    color("gray", alpha = 0.05)
      translate([-large_dimension -1, -1, -slop])
        cube([large_dimension, large_dimension, 2 * large_dimension]);
    trunk_for_print();
  }
}

// Generates a vertical slice to inspect leaf and trunk fitment
module leaves_and_trunk_sliver() {
  intersection()
  {
    color("gray", alpha = 0.05)
      translate([-1, -large_dimension, -slop])
        cube([2, 2 * large_dimension, 2 * large_dimension]);
    union() {
      trunk_for_print();
      leaves_stacked();
    }
  }
}

// Generates only the rings for quicker fitment test against the LED rings
module leaves_rings_only() {
  intersection()
  {
    color("gray", alpha = 0.05)
      translate([-large_dimension, -large_dimension, -slop])
        cube([2 * large_dimension, 2 * large_dimension, 2 * minimum_wall_thickness]);
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

  difference() 
  {
    color(color_leaves) union() {
      cylinder(h = layer_h, r = net_upper_r);
      cylinder(h = leaf_outer_edge_height + r_diff, r = lower_r);
    }

    // Carve the swoopy bit
    color(color_leaves, alpha = 0.6) {
      translate([0, 0, leaf_outer_edge_height + r_diff]) {
        donut(r1 = lower_r + r_diff, r2 = r_diff);
      }
    }

    // Carve the vertical trunk cavity
    color(color_leaves, alpha = 0.4) {
      translate([0, 0, -slop]) {
        cylinder(h = layer_h + 2 * slop, r = lower_trunk_r + slop);
      }
    }

    // Carve the horizontal cable raceway
    color(color_raceway, alpha = 0.4) {
      cable_raceway(lower_r, isBase = 0 == layer_index);
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
    color(color_trunk, alpha = 0.4)
    translate([0, 0, -slop]) {
      cylinder(h = layer_h + 2 * slop, r1 = lower_trunk_r - trunk_layer_overlap - nozzle_diameter, r2 = upper_trunk_r - trunk_layer_overlap - nozzle_diameter);
    }

    // Carve the horizontal cable raceway
    cable_raceway(lower_r);
    translate([0, 0, layer_h])
      rotate(a=[0,180,0])
        cable_raceway(lower_r);

    // Carve a vertical cable raceway
    color(color_raceway, alpha = 0.4)
    translate([-cable_raceway_width / 2, -slop, -slop]) {
      cube([cable_raceway_width, lower_trunk_r, layer_h + 2 * slop]);
    }

  }
}

// ===== UTILITIES ===== //

function calc_first_layer_index() =
  max(0, min(ring_radii_last_index, first_layer));

function calc_last_layer_index() =
  (last_layer < 0 || last_layer < first_layer)
    ? ring_radii_last_index
    : max(0, min(ring_radii_last_index, last_layer));

function calc_radii_at(layer_index) =
  layer_index < 0 
    ? ring_radii[0] 
    : layer_index > ring_radii_last_index 
      ? minimum_trunk_radius
      : ring_radii[layer_index];

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
  min(layer_index + 1, ring_radii_last_index);

// (H)
function calc_layer_h_at(layer_index) =
  leaf_outer_edge_height + calc_radii_at(layer_index) - max(minimum_trunk_radius, calc_radii_at(layer_index + 1) - ring_width - ring_inner_offset) + ring_height;

// (A)
function calc_outer_r_at(layer_index) =
  calc_radii_at(layer_index) + minimum_wall_thickness;

// (B)
function calc_net_upper_r_at(layer_index) =
  max(minimum_wall_thickness + minimum_trunk_radius, calc_radii_at(layer_index + 1) - ring_width - ring_inner_offset);

// (C)
function calc_net_inner_r_at(layer_index) =
  max(minimum_trunk_radius, calc_outer_r_at(layer_index) - calc_layer_h_at(layer_index) + minimum_wall_thickness);

// (A) - (B)
function calc_r_diff_at(layer_index) =
  calc_outer_r_at(layer_index) - calc_net_upper_r_at(layer_index);

module cable_raceway(lower_r, isBase = false)
  color(color_raceway, alpha = 0.4)
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
          // The base of the tree doesn't have a wall at the end of the raceway
          cylinder(h = cable_raceway_height * 2, r = isBase ? lower_r + slop : lower_r - minimum_wall_thickness);
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

// Given three tangental circles, returns the angle between the first two
function law_of_cosines_for_radii(a, b, c) =
  law_of_cosines(a + b, a + c, b + c);

function law_of_cosines(a, b, c) =
  acos((a^2 + b^2 - c^2) / (2 * a * b));

// EOF

