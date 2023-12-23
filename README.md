# HackerBox #0097 - Ringer

HackerBox #0095 can be [purchased here](https://hackerboxes.com/collections/past-hackerboxes/products/hackerbox-0097-ringer) and [built from the instructions](https://www.instructables.com/HackerBox-0097-Ringer/).

This repo provides a 3D model of a Pine Tree that can be used to support the LED rings from the HackerBox kit.

![Pine Tree viewable in OpenSCAD](images/ping-tree-openscad.png)

## Setup

Pre-requisites:
* [OpenSCAD](https://openscad.org/downloads.html#snapshots) version 2019.05 or newer (to be able to use the [Customizer](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Customizer) feature). This print was developed using 2023.07.09.
* [VSCode](https://code.visualstudio.com/download) Optional, applicable if you need to make changes that can't be done in the Customizer.

## Contents

### Pine Tree

The `PineTree.scad` file contains the 3D model of the pine tree. Pre-rendered STLs may be available in the STLs folder but may not have the latest changes. The model has been designed to be printed without support.

Open the file in OpenSCAD and use the Customizer to adjust the parameters to match your LED rings.

There are several views available in the Customizer:
* `Leaves (for print)` - This view is used to render the leaves for printing. It splits each leaf layer out in a way that can be printed without support. Individual leaves can be printed in combination with the first-layer/last-layer values.
* `Trunk (for print)` - This view is used to render the trunk for printing. It is a single piece that is designed to be printed without support. It includes a generous raceway for wiring.
* `Leaves stacked` - Makes a prettier picture but is not helpful for printing.
* `Leaves and trunk quartered` - (development) This helped visualize how the leaves would rest on the trunk.
* `Leaves and trunk sliver` - (development) This allowed comparing the horizontal wiring raceways.
* `Leaf rings only` - (development) This printed a minimal version of the leaves for comparison with the LED rings.

### Bill of Materials

The easiest way to get the may very well be to order [HackerBox #0095](https://hackerboxes.com/collections/past-hackerboxes/products/hackerbox-0097-ringer). But, at some point, that may not be available. The BOM is included here for reference.

* Set of five addressable RGB LED concentric ring boards (128 pixels). 
  * [AliExpress](https://www.aliexpress.us/item/3256803493397431.html)
  * If you want to search elsewhere, see the table below for details about the set included in the HackerBox kit. If you use a different set, you may need to manually update the `ring_radii[]` array in `pine-tree.scad`.
* You may want to add one addressable LED at the top.
  * [Adafruit](https://www.adafruit.com/product/1655) or [Adafruit](https://www.adafruit.com/product/2424)
  * Personally, I cut one off an unused WS2812B strip [Amazon](https://www.amazon.com/LOAMLIN-WS2812B-Individually-Addressable-Waterproof/dp/B0956C7KFR).
* An ESP32 Wi-Fi development board suitable for [WLED](https://kno.wled.ge/).
* Hookup wire
* ProTapes UGlu Dash Sheets to attach the LED rings under the leaves. This adhesive is not included in the HackerBox kit, so source it separately.
  * [Amazon](https://www.amazon.com/ProTapes-306UGLU600-UGlu-Dash-Sheets/dp/B06XCCRPRY)
  * [Adafruit](https://www.adafruit.com/product/2424)

#### LED Rings

| Ring | LEDs | Diameter | Radius  |
|------|------|----------|---------|
| 1    | 45   |   120 mm | 60 mm   |
| 2    | 35   |    96 mm | 48 mm   |
| 3    | 24   |    72 mm | 36 mm   |
| 4    | 16   |    48 mm | 24 mm   |
| 5    | 8    |    27 mm | 13.5 mm |

Total: 128 LEDs

### Assembly

The following instructions are specific to the Pine Tree. HackerBox provides [instructions](https://www.instructables.com/HackerBox-0097-Ringer/) on how to wire the LED rings and set up the ESP32.

1. Print the leaves and trunk.
1. The bottom layer is a base and is not intended to have LEDs under it. It can be identified by the gap in the outermost edge at the end of the raceway. Attach it to the trunk, making sure to align the cable raceways.
1. Beginning with the next layer up (the largest leaf), solder your hookup wire to the pads on the back of the LED rings. There are several ways to approach this.
  * Work each layer in order, attaching the wires to the back of the rings and feeding the wires through the raceway, daisy-chaining the rings together as you go.
  * Alternatively, before doing more assembly, solder four wires to each ring (Gnd, 5V, Data In, Data Out), leaving them long enough to be connected inside the trunk later.
1. Cut the UGlu Dash Sheets into smaller pieces, perhaps 4mm square. Using about three pieces per ring, center and attach the LED rings to the flat side of the leaves. Be sure to align the cable in the raceways.
1. Slide the leaves onto the trunk. The leaves should be snug but not so tight that they can't be removed. The leaves should be oriented so the raceways align with the raceway in the trunk.
