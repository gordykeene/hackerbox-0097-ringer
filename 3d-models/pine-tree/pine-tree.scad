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

render_options = ["Leafs (for print)", "Trunk (for print)", "Leafs stacked", "Leafs and trunk quartered", "Leafs and trunk sliver"];

/* [Viewing Options] */
// Select view to render
view = "Leafs (for print)"; // ["Leafs (for print)", "Trunk (for print)", "Leafs stacked", "Leafs and trunk quartered", "Leafs and trunk sliver"]

/* [LED Ring Measurements] */
// Width of the LED ring along x/y-plane (outer - inner diameters)
ring_width = 9;
// Additional space added inside the ring along x/y-plane
ring_inner_offset = 2;
// Height of the LED ring along z-axis
ring_height = 1.6;

/* [Cable Raceway Measurements] */
// Height of the horizontal cable raceway along z-axis
cable_raceway_height = 2;
// Width of the horizontal cable raceway along x-axis
cable_raceway_width = 20;
// Radius of the vertical cable raceway (minimum)
cable_raceway_radius = 3;

/* [Pine Tree Settings] */
// Minimum radius of the trunk
minimum_trunk_radius = 2;

/* [Tweaks and adjustments] */
$fa = 8.0;
$fs = 0.25;
// extra space to add to the outside of the object when used as a void.
slop = 0.01;

// This is a hack to ensure the Customizer ignores the rest of the values in this file.
module end_customizer() {}

// I really wish I could have included these in the Customizer, but it's not possible.
// The first "ring" is not a ring, rather it's the trunk of the tree.
// Per the documentation, the ring_diameters are: 120, 96, 72, 48, 27
// ring_radii = [minimum_trunk_radius, 13.5, 24, 36, 48, 60, 60];
ring_radii = [60, 60, 48, 36, 24, 13.5, minimum_trunk_radius];

// Calulated values
leaf_outer_edge_height = cable_raceway_height + 0.4;

// Colors
color_leafs = "Green";
color_trunk = "#362312";
color_raceway = "FireBrick";

// ===== IMPLEMENTATION ===== //

main();

module main() {
  if (render_options[0] == view) leafs_for_print();
  if (render_options[1] == view) trunk_for_print();
  if (render_options[2] == view) leafs_stacked();
  if (render_options[3] == view) leafs_and_trunk_quartered();
  if (render_options[4] == view) leafs_and_trunk_sliver();
}

module leafs_for_print() {
  spacer = 3;
  center_r = ring_radii[0] + spacer;

  leaf_at(1);

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
  translate([0, 0, leaf_layer_height(0)]) {
    trunk_at(1);
    translate([0, 0, leaf_layer_height(1)]) {
      trunk_at(2);
      translate([0, 0, leaf_layer_height(2)]) {
        trunk_at(3);
        translate([0, 0, leaf_layer_height(3)]) {
          trunk_at(4);
          translate([0, 0, leaf_layer_height(4)]) {
            trunk_at(5);
          }
        }
      }
    }
  }
}

module leafs_stacked() {
  leaf_at(0);
  translate([0, 0, leaf_layer_height(0)]) {
    leaf_at(1);
    translate([0, 0, leaf_layer_height(1)]) {
      leaf_at(2);
      translate([0, 0, leaf_layer_height(2)]) {
        leaf_at(3);
        translate([0, 0, leaf_layer_height(3)]) {
          leaf_at(4);
          translate([0, 0, leaf_layer_height(4)]) {
            leaf_at(5);
          }
        }
      }
    }
  }
}

module leafs_and_trunk_quartered() {
  k = 100; // Some value larger than the objects in most dimensions
  intersection() {
    color("gray", alpha=0.05)
      translate([-k, -k, -slop]) 
        cube([k, k, 2 * k]);
    leafs_stacked();
  }
  intersection() {
    color("gray", alpha=0.05)
      translate([-k, 0, -slop])
        cube([k, k, 2 * k]);
    trunk_for_print();
  }
}

module leafs_and_trunk_sliver() {
  k = 100; // Some value larger than the objects in most dimensions
  intersection()
  {
    color("gray", alpha=0.05)
      translate([-1, -k, -slop])
        cube([2, 2 * k, 2 * k]);
    union() {
      trunk_for_print();
      leafs_stacked();
    }
  }
}

// ===== LEAF RINGS ===== //

module leaf_at(layer_index) {
  layer_h = leaf_layer_height(layer_index);
  outer_r = ring_radii[layer_index];
  inner_r = ring_radii[layer_index + 1];
  echo("leaf. layer_h: ", layer_h, "inner_r: ", inner_r, ", outer_r: ", outer_r);

  net_inner_r = max(1.2 + minimum_trunk_radius, inner_r - ring_width - ring_inner_offset);
  trunk_r = net_inner_r / 2;
  r_diff = outer_r - net_inner_r;
  echo("leaf. net_inner_r: ", net_inner_r, ", r_diff: ", r_diff);

  difference() 
  {
    color(color_leafs) union() {
      cylinder(h = layer_h, r = net_inner_r);
      cylinder(h = leaf_outer_edge_height + r_diff, r = outer_r);
    }

    // Carve the swoopy bit
    color(color_leafs, alpha=0.4) {
      translate([0, 0, leaf_outer_edge_height + r_diff]) {
        donut(r1 = outer_r + r_diff, r2 = r_diff);
      }
    }

    // Carve the vertical trunk cavity
    color(color_leafs, alpha=0.4) {
      translate([0, 0, -slop]) {
        cylinder(h = layer_h + 2 * slop, r = trunk_r);
      }
    }

    // Carve the horizontal cable raceway
    color(color_raceway, alpha=0.4) {
      cable_raceway(outer_r);
    }
  }
}

// ===== TRUNK RINGS ===== //

module trunk_at(layer_index) {
  overlap = 1.4;
  layer_h = leaf_layer_height(layer_index);
  outer_r = ring_radii[layer_index];
  inner_r = ring_radii[layer_index + 1];
  echo("trunk. inner_r: ", inner_r, ", outer_r: ", outer_r, "layer_h: ", layer_h);

  net_outer_r = max(1.2 + minimum_trunk_radius, outer_r - ring_width - ring_inner_offset);
  net_inner_r = max(1.2 + minimum_trunk_radius, inner_r - ring_width - ring_inner_offset);
  r_diff = net_outer_r - net_inner_r;
  trunk_r = net_inner_r / 2;
  echo("trunk. net_outer_r: ", net_outer_r, ", net_inner_r: ", net_inner_r, ", r_diff: ", r_diff);

  difference() 
  {
    color(color_trunk) {
      cylinder(h = layer_h, r1 = trunk_r, r2 = trunk_r - 0.8);
    }

    // Carve the vertical trunk cavity
    color(color_trunk, alpha=0.4)
    translate([0, 0, -slop]) {
      cylinder(h = layer_h + 2 * slop, r1 = trunk_r - overlap, r2 = (inner_r - overlap) / 4);
    }

    // Carve the horizontal cable raceway
    cable_raceway(net_outer_r);
    translate([0, 0, layer_h])
      rotate(a=[0,180,0])
        cable_raceway(net_outer_r);
  }
}

// ===== UTILITIES ===== //

function leaf_layer_height(layer_index) =
  leaf_outer_edge_height + ring_radii[layer_index] - max(minimum_trunk_radius, ring_radii[layer_index + 1] - ring_width - ring_inner_offset) + ring_height;

function leaf_layer_height_delme(outer_r, inner_r) =
  leaf_outer_edge_height + outer_r - max(minimum_trunk_radius, inner_r - ring_width - ring_inner_offset) + ring_height;

module cable_raceway(outer_r)
  color(color_raceway, alpha=0.4)
    rotate(a=[0, 0, 90])
      translate([0, 0, -slop])
        intersection() {
          union() {
            translate([0, 0, cable_raceway_height / 2])
              rotate(a=[0, 90, 0]) 
                scale([cable_raceway_height, cable_raceway_width])
                  cylinder(outer_r - 1 + 2 * slop, d = 1);
            translate([0, -cable_raceway_width / 2, 0])
              cube([outer_r - 1, cable_raceway_width, cable_raceway_height / 2]);
          }
          cylinder(h = cable_raceway_height * 2, r = outer_r - 1.2);
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
