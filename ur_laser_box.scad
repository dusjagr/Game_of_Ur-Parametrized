// Laser-Cut Notched Box for Game of Ur
// Generated from parametrically calculated coordinates
//
// --- History of the Game ---
// The Royal Game of Ur is an ancient Mesopotamian board game played from the early 
// third millennium BC (c. 2600-2400 BC). It is a two-player race game played with 
// sets of seven markers and four tetrahedral dice. The game was famously rediscovered 
// by English archaeologist Sir Leonard Woolley during his excavations of the Royal 
// Cemetery at Ur between 1922 and 1934, making it one of the oldest known board games 
// in human history. 
// Read more: https://en.wikipedia.org/wiki/Royal_Game_of_Ur
// 
// Acknowledgements & Credits:
// The structural design was inspired by and adapted from:
// https://www.thingiverse.com/thing:2809371 (by DonaldSayers)
// The top surface engraving (Ur_edge.dxf) is also sourced from this project.
//
// AI Agentic Coding & Development Process:
// This fully parametric OpenSCAD design was developed iteratively through pair-programming
// between a human user and Antigravity, an agentic AI coding assistant from Google DeepMind.
// 
// Software: OpenSCAD, LightBurn (for laser cutting)
// AI Models: Gemini 3.1 Pro (via the Antigravity agent framework)
// Process: We started by mapping the 12-sided mathematical bounds of the original vector board.
// The agent then dynamically calculated angles and lengths to generate perfectly interlocking 
// finger joints (handling both convex and concave geometry), boolean-subtracted a sliding drawer,
// and implemented dedicated 2D output modes for cuts vs. negative/positive space engravings.
//
// Estimated AI Compute Usage: ~400,000 Input Tokens, ~25,000 Output Tokens
// Estimated API Cost: ~$0.15 - $0.30 USD

/* [Output Selection] */
// Select what you want to generate
output_mode = "3D"; // ["3D":"3D Assembly Preview", "2D":"2D Laser Cut Layout", "2D_ENGRAVE":"2D Engraving Layout", "DICE":"3D Printable Dice", "PIECE":"3D Printable Piece"]

/* [Box Dimensions] */
// Thickness of your material (e.g. plywood/acrylic)
material_thickness = 5; // [2:0.1:10]
// Internal height of the box (Total outer height is box_height + 2*material_thickness)
box_height = 25; // [15:1:60]
// Approximate width of the finger joints (notches)
tab_width = 18; // [10:1:40]
// Cut kerf compensation (0 for default, or small value like 0.1)
kerf_offset = 0; // [0:0.01:0.5]
// Total length of the board (long side, 8 squares)
board_length = 255; // [150:1:400]

// The following are derived from board_length based on optimized ratios for a 267mm board:
border_width = board_length * (3.5 / 267);
bridge_extra_width = board_length * (6 / 267);
inner_extra_width = board_length * (1.4 / 267);

/* [Box Options] */
// If true, top plate has no finger joints and is glued flush
flush_top_plate = true; 

/* [Engraving Options] */
// Generate geometric engraving patterns on the side walls
include_side_engravings = true; 
// Engrave the rules tablet on the inside of the drawer base plate
include_drawer_engraving = false; 

/* [Drawer Options] */
// Add an optional slide-out drawer
include_drawer = true; 
// How far the drawer is pulled out in 3D preview
drawer_pull_out = 150; // [0:1:250]
// Gap around the drawer so it slides smoothly
drawer_clearance = 0.5; // [0:0.1:2.0]

/* [Dice Options] */
// Show 3D printed tetrahedron dice in the assembly preview
include_dice = true; 
// Standard Game of Ur uses 4 dice per player (8 total)
num_dice = 4; // [0:1:8]
// Edge length of the tetrahedron dice
dice_edge = 22; // [10:1:40]
// Roundness of the dice corners
dice_corner_radius = 1.2; // [0:0.1:5.0]
// Position of the corner marking (0.0 = center of face, 1.0 = right at the tip)
dice_mark_pos = 0.65; // [0:0.05:1.0]
// Size of the triangular marking relative to the dice edge
dice_mark_size = 0.16; // [0.05:0.01:0.3]

/* [Piece Options] */
// Show play pieces in the assembly preview
include_pieces = true; 
// Style of play pieces
piece_type = "LASER"; // ["3D":"3D Rounded Printable", "LASER":"Flat Laser-Cut"]
// Ratio of piece diameter to board square size
piece_ratio = 0.65; // [0.5:0.01:0.9]
// Ratio of piece height to piece diameter
piece_height_ratio = 0.30; // [0.1:0.01:0.8]
// Standard Game of Ur uses 7 pieces per player (14 total)
num_pieces = 14; // [0:1:14]

/* [Wall Engraving Patterns] */
// E = Eye, S = Stripes, T = Triangles, 0 = Blank. Length should match the wall's grid length.
// Wall 1: Top-Left (Length 4)
wall_1_pattern = "SEES"; 
// Wall 2: Top-Right of Left Block (Length 1)
wall_2_pattern = "S"; 
// Wall 3: Inner Top-Left / Bridge (Length 2)
wall_3_pattern = "EE"; 
// Wall 4: Inner Top-Right (Length 1)
wall_4_pattern = "T"; 
// Wall 5: Top-Left of Right Block (Length 2)
wall_5_pattern = "ET"; 
// Wall 6: Top-Right Edge (Length 3)
wall_6_pattern = "TTT"; 
// Wall 7: Bottom-Right Edge (Length 2)
wall_7_pattern = "TE"; 
// Wall 8: Bottom-Left of Right Block (Length 1)
wall_8_pattern = "T"; 
// Wall 9: Inner Bottom-Right / Bridge (Length 2)
wall_9_pattern = "EE"; 
// Wall 10: Inner Bottom-Left (Length 1)
wall_10_pattern = "S"; 
// Wall 11: Bottom-Right of Left Block (Length 4)
wall_11_pattern = "SEES"; 
// Wall 12: Drawer Front (Length 3)
wall_12_pattern = "S0S"; 

/* [Hidden] */

// Pattern definitions for the 12 walls
wall_patterns = [
  wall_1_pattern,
  wall_2_pattern,
  wall_3_pattern,
  wall_4_pattern,
  wall_5_pattern,
  wall_6_pattern,
  wall_7_pattern,
  wall_8_pattern,
  wall_9_pattern,
  wall_10_pattern,
  wall_11_pattern,
  wall_12_pattern
];

// Derived dimensions to guarantee perfect squares (8:3 tile ratio)
sq_size = (board_length - 2 * border_width) / 8;
board_width = 3 * sq_size + 2 * border_width;

// Alias to maintain compatibility with the point generation
sq_x = sq_size;
sq_y = sq_size;

// Calculate drawer depth to exactly hit the inner back wall when front is flush
drawer_depth = 4 * sq_x + 2 * border_width + inner_extra_width - 2 * material_thickness;

// The 12 vertices of the board generated parametrically (Clockwise)
pts = [
  [-border_width, 3 * sq_y + border_width], // 1. Top-Left
  [4 * sq_x + border_width + inner_extra_width, 3 * sq_y + border_width], // 2. Top-Right (Left Block)
  [4 * sq_x + border_width + inner_extra_width, 2 * sq_y + border_width + bridge_extra_width], // 3. Inner Top-Left
  [6 * sq_x - border_width - inner_extra_width, 2 * sq_y + border_width + bridge_extra_width], // 4. Inner Top-Right
  [6 * sq_x - border_width - inner_extra_width, 3 * sq_y + border_width], // 5. Top-Left (Right Block)
  [8 * sq_x + border_width, 3 * sq_y + border_width], // 6. Top-Right
  [8 * sq_x + border_width, -border_width], // 7. Bottom-Right
  [6 * sq_x - border_width - inner_extra_width, -border_width], // 8. Bottom-Left (Right Block)
  [6 * sq_x - border_width - inner_extra_width, sq_y - border_width - bridge_extra_width], // 9. Inner Bottom-Right
  [4 * sq_x + border_width + inner_extra_width, sq_y - border_width - bridge_extra_width], // 10. Inner Bottom-Left
  [4 * sq_x + border_width + inner_extra_width, -border_width], // 11. Bottom-Right (Left Block)
  [-border_width, -border_width], // 12. Bottom-Left
];
num_pts = len(pts);

// --- Math Functions ---
function get_len(p1, p2) = norm(p2 - p1);
function get_angle(p1, p2) = atan2(p2[1] - p1[1], p2[0] - p1[0]);

lengths = [for (i = [0:num_pts - 1]) get_len(pts[i], pts[ (i + 1) % num_pts])];

function is_concave(i) =
  let (
    prev = (i - 1 + num_pts) % num_pts,
    next = (i + 1) % num_pts,
    v1 = pts[i] - pts[prev],
    v2 = pts[next] - pts[i],
    cz = v1[0] * v2[1] - v1[1] * v2[0]
  ) cz > 0;

// --- Modules ---

// Align and scale the DXF engraving to match the parametric board size
module engraving_layer() {
  // SVG bounding box from Potrace (2984x1175 points)
  // OpenSCAD automatically converts pt to mm (1 pt = 25.4 / 72 mm)
  svg_orig_x = 0;
  svg_orig_y = 0;
  pt_to_mm = 25.4 / 72;
  svg_orig_width = 2984 * pt_to_mm;
  svg_orig_height = 1175 * pt_to_mm;

  // Target dimensions with 1.5mm gap on all sides
  target_width = board_length - 3.0;
  target_height = board_width - 3.0;

  scale_x = target_width / svg_orig_width;
  scale_y = target_height / svg_orig_height;

  translate([-border_width + 1.5, -border_width + 1.5])
    scale([scale_x, scale_y])
      translate([-svg_orig_x, -svg_orig_y])
        import("Ur_engraving_clean.svg");
}

// Drawer sub-components
module drawer_plate(w, h, tabs_top = 0, tabs_bottom = 0, tabs_left = 0, tabs_right = 0) {
  t = material_thickness;
  nx = max(3, floor(w / tab_width));
  nx_odd = nx % 2 == 0 ? nx + 1 : nx;
  tx = w / nx_odd;

  ny = max(3, floor(h / tab_width));
  ny_odd = ny % 2 == 0 ? ny + 1 : ny;
  ty = h / ny_odd;

  difference() {
    union() {
      square([w, h]);
      if (tabs_top == 1) for (i = [1:2:nx_odd - 1]) translate([i * tx, h - 0.01]) square([tx, t + 0.01]);
      if (tabs_bottom == 1) for (i = [1:2:nx_odd - 1]) translate([i * tx, -t]) square([tx, t + 0.01]);
      if (tabs_left == 1) for (i = [1:2:ny_odd - 1]) translate([-t, i * ty]) square([t + 0.01, ty]);
      if (tabs_right == 1) for (i = [1:2:ny_odd - 1]) translate([w - 0.01, i * ty]) square([t + 0.01, ty]);
    }
    if (tabs_top == -1) for (i = [1:2:nx_odd - 1]) translate([i * tx, h - t - 0.01]) square([tx, t + 0.02]);
    if (tabs_bottom == -1) for (i = [1:2:nx_odd - 1]) translate([i * tx, -0.01]) square([tx, t + 0.02]);
    if (tabs_left == -1) for (i = [1:2:ny_odd - 1]) translate([-0.01, i * ty]) square([t + 0.02, ty]);
    if (tabs_right == -1) for (i = [1:2:ny_odd - 1]) translate([w - t - 0.01, i * ty]) square([t + 0.02, ty]);

    if (tabs_top == -2) for (i = [0:2:nx_odd - 1]) translate([i * tx, h - t - 0.01]) square([tx, t + 0.02]);
    if (tabs_bottom == -2) for (i = [0:2:nx_odd - 1]) translate([i * tx, -0.01]) square([tx, t + 0.02]);
    if (tabs_left == -2) for (i = [0:2:ny_odd - 1]) translate([-0.01, i * ty]) square([t + 0.02, ty]);
    if (tabs_right == -2) for (i = [0:2:ny_odd - 1]) translate([w - t - 0.01, i * ty]) square([t + 0.02, ty]);
  }
}

module drawer_front_plate(dw, dh) {
  t = material_thickness;
  front_w = dw + 2 * t;
  front_h = dh;

  offset_x = t;
  offset_y = 0;

  difference() {
    square([front_w, front_h]);

    translate([offset_x, offset_y]) {
      nx = max(3, floor(dw / tab_width));
      nx_odd = nx % 2 == 0 ? nx + 1 : nx;
      tx = dw / nx_odd;
      for (i = [1:2:nx_odd - 1]) translate([i * tx, 0]) square([tx, t]);
    }

    // Left wall slots (at X=0)
    ny = max(3, floor(dh / tab_width));
    ny_odd = ny % 2 == 0 ? ny + 1 : ny;
    ty = dh / ny_odd;
    for (i = [1:2:ny_odd - 1]) translate([0, i * ty]) square([t, ty]);

    // Right wall slots (at X=dw+t)
    for (i = [1:2:ny_odd - 1]) translate([dw + t, i * ty]) square([t, ty]);

    // Finger hole
    translate([front_w / 2, front_h - 12]) circle(d=12, $fn=32);
  }
}

module drawer_engraving(w, h) {
  svg_w = 126.61512;
  svg_h = 189.43352;
  
  // Calculate scale to fit inside the drawer base with a 3mm margin
  scale_factor = min((w - 6) / svg_w, (h - 6) / svg_h);
  
  actual_w = svg_w * scale_factor;
  actual_h = svg_h * scale_factor;
  
  // Center the engraving on the plate
  translate([(w - actual_w) / 2, (h - actual_h) / 2])
    scale([scale_factor, scale_factor])
      import("rules_tablet.svg");
}

module drawer_parts(mode = "2D") {
  t = material_thickness;
  dw = lengths[11] - 4 * t - 2 * drawer_clearance;
  dd = drawer_depth;
  dh = box_height - drawer_clearance;
  spacing = 15;

  if (mode == "2D") {
    // Base
    drawer_plate(dw, dd, -1, 1, 1, 1);
    // Back
    translate([dw + spacing, 0]) drawer_plate(dw, dh, 0, -2, 1, 1);
    // Left
    translate([0, dd + spacing]) drawer_plate(dd, dh, 0, -1, 1, -1);
    // Right
    translate([dd + spacing, dd + spacing]) drawer_plate(dd, dh, 0, -1, 1, -1);
    // Front
    translate([0, dd + dh + 2 * spacing]) {
      drawer_front_plate(dw, dh);
    }
  } else if (mode == "2D_ENGRAVE") {
    // Base Engraving (Rules)
    if (include_drawer_engraving) {
      drawer_engraving(dw, dd);
    }
    
    // Front Engraving
    translate([0, dd + dh + 2 * spacing]) {
      translate([-t, 0])
        sidewall_engraving(dw + 2 * t, box_height, wall_patterns[11]);
    }
  }
}

module drawer_3d() {
  t = material_thickness;
  dw = lengths[11] - 4 * t - 2 * drawer_clearance;
  dd = drawer_depth;
  dh = box_height - drawer_clearance;

  color("peru") {
    linear_extrude(height=t) drawer_plate(dw, dd, -1, 1, 1, 1);
  }
  
  // 3D Preview of the Rules Engraving on the inside bottom of the drawer
  if (include_drawer_engraving) {
    color("darkred") translate([0, 0, t - 0.01]) linear_extrude(height=0.51)
      drawer_engraving(dw, dd);
  }

  color("sandybrown") translate([0, dd, 0]) rotate([90, 0, 0]) linear_extrude(height=t)
          drawer_plate(dw, dh, 0, -2, 1, 1);

  color("burlywood") translate([-t, 0, 0]) rotate([90, 0, 90]) linear_extrude(height=t)
          drawer_plate(dd, dh, 0, -1, 1, -1);

  color("burlywood") translate([dw, 0, 0]) rotate([90, 0, 90]) linear_extrude(height=t)
          drawer_plate(dd, dh, 0, -1, 1, -1);

  color("saddlebrown") translate([-t, 0, 0]) rotate([90, 0, 0]) linear_extrude(height=t)
          drawer_front_plate(dw, dh);

  if (include_side_engravings) {
    color("darkred") translate([-t, 0, 0]) rotate([90, 0, 0])
          translate([0, 0, t - 0.01]) linear_extrude(height=0.51)
              sidewall_engraving(dw + 2 * t, box_height, wall_patterns[11]);
  }
}

module sidewall_engraving(L, h, pattern = "") {
  margin_y = 3;

  // Top and bottom borders (filled strips). Shrink slightly in X to avoid CGAL non-manifold edges.
  translate([0.01, margin_y]) square([L - 0.02, 1.5]);
  translate([0.01, h - margin_y - 1.5]) square([L - 0.02, 1.5]);

  // Split L into cells
  num_cells = len(pattern);
  if (num_cells > 0) {
    actual_w = L / num_cells;

    for (i = [0:num_cells - 1]) {
      char = pattern[i];
      prev_char = (i > 0) ? pattern[i - 1] : "";

      // Cell separator (thick line) - Skip if joining two Triangle cells
      if (i > 0 && !(char == "T" && prev_char == "T")) {
        translate([i * actual_w - 1, margin_y]) square([2, h - 2 * margin_y]);
      }

      cx = i * actual_w + actual_w / 2;
      cy = h / 2;

      if (char == "E") {
        // Eye motif (almond shape)
        ew = actual_w * 0.60;
        eh = (h - 2 * margin_y) * 0.50;

        // Thin vertical flanking lines touching the eye tips
        translate([cx - ew / 2 - 0.5, margin_y + 1]) square([1, h - 2 * margin_y - 2]);
        translate([cx + ew / 2 - 0.5, margin_y + 1]) square([1, h - 2 * margin_y - 2]);

        r_outer = (ew * ew + eh * eh) / (4 * eh);
        dy_outer = r_outer - eh / 2;

        ew_in = ew - 3;
        eh_in = eh - 3;
        r_inner = (ew_in * ew_in + eh_in * eh_in) / (4 * eh_in);
        dy_inner = r_inner - eh_in / 2;

        translate([cx, cy]) {
          difference() {
            intersection() {
              translate([0, dy_outer]) circle(r=r_outer, $fn=64);
              translate([0, -dy_outer]) circle(r=r_outer, $fn=64);
            }
            intersection() {
              translate([0, dy_inner]) circle(r=r_inner, $fn=64);
              translate([0, -dy_inner]) circle(r=r_inner, $fn=64);
            }
          }
          // Pupil
          circle(r=eh * 0.25, $fn=32);
        }
      } else if (char == "S") {
        // Vertical stripes
        stripe_w = actual_w * 0.15;
        spacing = (actual_w - 3 * stripe_w) / 4;
        for (j = [0:2]) {
          translate([i * actual_w + spacing + j * (stripe_w + spacing), margin_y + 1.5])
            square([stripe_w, h - 2 * margin_y - 3]);
        }
      } else if (char == "T") {
        // Vertical triangles / teeth
        tri_w = actual_w / 3;
        for (j = [0:2]) {
          // Up pointing triangle
          translate([i * actual_w + j * tri_w, margin_y + 1.5])
            polygon([[0, 0], [tri_w, 0], [tri_w / 2, h - 2 * margin_y - 3]]);
        }
      }
    }
  }
}

// A single side wall with tabs on the bottom, top, and sides
module side_wall(i, L) {
  t = material_thickness;

  concave_start = is_concave(i);
  concave_end = is_concave((i + 1) % num_pts);

  start_x = concave_start ? -t : 0;
  end_x = L + (concave_end ? t : 0);

  num_z = max(3, round(box_height / tab_width));
  tab_h = box_height / num_z;

  num_x = max(3, floor(L / tab_width));
  nx = num_x % 2 == 0 ? num_x + 1 : num_x; // ensure odd
  tab_w_x = L / nx;

  union() {
    difference() {
      // Main body
      translate([start_x, 0]) square([end_x - start_x, box_height]);

      // Left and right edge cutouts (finger joints)
      for (k = [0:num_z - 1]) {
        if ( (i + k) % 2 != 0) {
          if (!(include_drawer && i == 0)) {
            translate([start_x - 0.01, k * tab_h]) square([t + 0.02, tab_h + 0.01]);
          }
        }
        if ( (i + 1 + k) % 2 == 0) {
          if (!(include_drawer && i == 10)) {
            translate([end_x - t - 0.01, k * tab_h]) square([t + 0.02, tab_h + 0.01]);
          }
        }
      }
    }

    // Bottom tabs (to lock into base plate)
    for (j = [0:nx - 1]) {
      if (j % 2 == 0) {
        tab_start_offset = (i % 2 != 0 && j == 0 && !concave_start) ? t : 0;
        tab_end_offset = (i % 2 != 0 && j == nx - 1 && !concave_end) ? t : 0;
        translate([j * tab_w_x + tab_start_offset, -t])
          square([tab_w_x - tab_start_offset - tab_end_offset, t + 0.01]);
      }
    }

    // Top tabs (to lock into top plate)
    if (!flush_top_plate) {
      for (j = [0:nx - 1]) {
        if (j % 2 == 0) {
          tab_start_offset = (i % 2 != 0 && j == 0 && !concave_start) ? t : 0;
          tab_end_offset = (i % 2 != 0 && j == nx - 1 && !concave_end) ? t : 0;
          translate([j * tab_w_x + tab_start_offset, box_height - 0.01])
            square([tab_w_x - tab_start_offset - tab_end_offset, t + 0.01]);
        }
      }
    }
  }
}

module side_walls_layout(mode = "2D") {
  spacing = box_height + 20;
  for (i = [0:num_pts - 1]) {
    if (!(include_drawer && i == 11)) {
      row = floor(i / 2);
      col = i % 2;
      x_offset = col * (max(lengths) + 30);
      y_offset = row * spacing;

      translate([x_offset, -y_offset - spacing]) {
        if (mode == "2D") {
          side_wall(i, lengths[i]);
          translate([lengths[i] / 2, box_height / 2])
            text(str("W", i + 1), size=4, halign="center", valign="center");
        } else if (mode == "2D_ENGRAVE") {
          sidewall_engraving(lengths[i], box_height, wall_patterns[i]);
        }
      }
    }
  }
}

// Parametric Rounded Tetrahedron for Dice
module rounded_tetrahedron(edge_length = 50, corner_radius = 5, mark_pos = 0.75, mark_size = 0.12, center = false) {
  // Constrain corner radius to prevent negative lengths
  r = max(0.001, min(corner_radius, edge_length / 2 - 0.001));

  // Calculate the internal center-to-center distance for the corner spheres
  e = edge_length - 2 * r;

  // Height of the internal tetrahedron (distance from base to top vertex)
  h = e * sqrt(2 / 3);

  // Centroid Z position (relative to the base vertices)
  centroid_z = h / 4;

  // Translation to apply based on centering preference
  z_trans = center ? -centroid_z : r;

  translate([0, 0, z_trans])
    difference() {
      hull() {
        // Base vertices (equilateral triangle)
        translate([e / sqrt(3), 0, 0]) sphere(r=r, $fn=64);
        translate([-e / (2 * sqrt(3)), e / 2, 0]) sphere(r=r, $fn=64);
        translate([-e / (2 * sqrt(3)), -e / 2, 0]) sphere(r=r, $fn=64);

        // Top vertex
        translate([0, 0, h]) sphere(r=r, $fn=64);
      }

      // 4 Internal vertices for reference
      p0 = [e / sqrt(3), 0, 0];
      p1 = [-e / (2 * sqrt(3)), e / 2, 0];
      p2 = [-e / (2 * sqrt(3)), -e / 2, 0];
      p3 = [0, 0, h];

      // Mark 3 faces around Top Vertex (p3)
      corner_mark(p0, p3, p1, p2, h, r, edge_length, mark_pos, mark_size);
      corner_mark(p1, p3, p2, p0, h, r, edge_length, mark_pos, mark_size);
      corner_mark(p2, p3, p0, p1, h, r, edge_length, mark_pos, mark_size);

      // Mark 3 faces around Base Vertex 0 (p0)
      corner_mark(p1, p0, p3, p2, h, r, edge_length, mark_pos, mark_size);
      corner_mark(p2, p0, p1, p3, h, r, edge_length, mark_pos, mark_size);
      corner_mark(p3, p0, p2, p1, h, r, edge_length, mark_pos, mark_size);
    }
}

// Helper module to place a triangular cut on a face near a corner
module corner_mark(p_opp, p_corner, p_a, p_b, h, r, edge_length, mark_pos, mark_size) {
  C = [0, 0, h / 4];
  N = (C - p_opp) / norm(C - p_opp); // Outward normal of the face

  face_center = (p_corner + p_a + p_b) / 3;

  // Position on the flat face, controlled by mark_pos (0 = center, 1 = tip)
  pos = p_corner * mark_pos + face_center * (1 - mark_pos);
  surface_pos = pos + N * (r + 0.1); // Shift to outer flat surface

  // Orient the triangular pyramid
  Z_dir = -N; // Point inwards
  X_dir = (p_corner - face_center) / norm(p_corner - face_center); // Triangle point faces towards corner
  Y_dir = cross(Z_dir, X_dir);

  M = [
    [X_dir[0], Y_dir[0], Z_dir[0], surface_pos[0]],
    [X_dir[1], Y_dir[1], Z_dir[1], surface_pos[1]],
    [X_dir[2], Y_dir[2], Z_dir[2], surface_pos[2]],
    [0, 0, 0, 1],
  ];

  multmatrix(M)
    // r2 is slightly smaller than r1 to give the pocket a nice draft angle for 3D printing
    cylinder(r1=edge_length * mark_size, r2=edge_length * (mark_size * 0.75), h=1.0, $fn=3);
}

// Parametric Game of Ur Play Piece
module ur_piece(diameter, height) {
  r = diameter / 2;
  // Fillet radius
  fillet = min(height / 2.2, r / 4);

  difference() {
    rotate_extrude($fn=64) {
      hull() {
        translate([r - fillet, fillet]) circle(r=fillet, $fn=32);
        translate([r - fillet, height - fillet]) circle(r=fillet, $fn=32);
        square([r - fillet, height]);
      }
    }

    // 5 indents on top
    indent_r = diameter * 0.08;
    indent_depth = height * 0.1; // Shallower embossing (was previously unused, spheres were going full radius deep)
    indent_dist = r * 0.55;

    // 4 surrounding dimples
    for (i = [0:3]) {
      rotate([0, 0, i * 90])
        translate([indent_dist, 0, height])
          scale([1, 1, indent_depth / indent_r])
            sphere(r=indent_r, $fn=32);
    }
    // Center dimple
    translate([0, 0, height])
      scale([1, 1, indent_depth / indent_r])
        sphere(r=indent_r, $fn=32);
  }
}

module ur_piece_laser_engraving(piece_d, player) {
  indent_r = piece_d * 0.08;
  indent_dist = (piece_d / 2) * 0.55;
  if (player == 1) {
    difference() {
      circle(d=piece_d, $fn=64);
      for (j = [0:3]) {
        rotate([0, 0, j * 90]) translate([indent_dist, 0]) circle(r=indent_r, $fn=32);
      }
      circle(r=indent_r, $fn=32);
    }
  } else {
    for (j = [0:3]) {
      rotate([0, 0, j * 90]) translate([indent_dist, 0]) circle(r=indent_r, $fn=32);
    }
    circle(r=indent_r, $fn=32);
  }
}

// Generates the shape with slotted perimeter used for both Top and Base plates
module slotted_plate_shape(is_flush = false) {
  difference() {
    union() {
      polygon(pts);
      // Add t x t square at each inner corner to cover the wall extensions
      for (i = [0:num_pts - 1]) {
        if (is_concave(i)) {
          p1 = pts[i];
          p2 = pts[ (i + 1) % num_pts];
          angle = get_angle(p1, p2);
          translate(p1) rotate(angle)
              translate([-material_thickness, -material_thickness])
                square([material_thickness, material_thickness + 0.01]);
        }
      }
    }

    if (!is_flush) {
      for (i = [0:num_pts - 1]) {
        if (!(include_drawer && i == 11)) {
          p1 = pts[i];
          p2 = pts[ (i + 1) % num_pts];
          L = lengths[i];
          angle = get_angle(p1, p2);

          num_x = max(3, floor(L / tab_width));
          nx = num_x % 2 == 0 ? num_x + 1 : num_x;
          tab_w_x = L / nx;

          translate(p1)
            rotate(angle) {
              for (j = [0:nx - 1]) {
                if (j % 2 == 0) {
                  translate([j * tab_w_x, -material_thickness - 0.01])
                    square([tab_w_x, material_thickness + 0.02]);
                }
              }
            }
        }
      }
    }
  }
}

module assembly_3d() {
  // 1. Base plate
  color("burlywood")
    linear_extrude(height=material_thickness)
      slotted_plate_shape();

  // 2. Side walls
  for (i = [0:num_pts - 1]) {
    if (!(include_drawer && i == 11)) {
      p1 = pts[i];
      p2 = pts[ (i + 1) % num_pts];
      L = lengths[i];
      angle = get_angle(p1, p2);

      c = (i % 2 == 0) ? "peru" : "sandybrown";

      color(c)
        translate([p1[0], p1[1], material_thickness])
          rotate([0, 0, angle])
            rotate([90, 0, 0])
              linear_extrude(height=material_thickness)
                side_wall(i, L);

      if (include_side_engravings) {
        color("darkred")
          translate([p1[0], p1[1], material_thickness])
            rotate([0, 0, angle])
              rotate([90, 0, 0])
                translate([0, 0, -0.5])
                  linear_extrude(height=0.51)
                    sidewall_engraving(L, box_height, wall_patterns[i]);
      }
    }
  }

  // 3. Top Plate
  color("burlywood")
    translate([0, 0, box_height + material_thickness])
      linear_extrude(height=material_thickness)
        slotted_plate_shape(flush_top_plate);

  // 4. Engraving Layer (on Top Plate)
  color("saddlebrown")
    translate([0, 0, box_height + material_thickness * 2 + 0.1])
      linear_extrude(height=0.5)
        engraving_layer();

  // 5. Drawer
  if (include_drawer) {
    pull_out = drawer_pull_out;
    center_y = 1.5 * sq_y;
    t = material_thickness;
    dw = lengths[11] - 4 * t - 2 * drawer_clearance;

    translate([-border_width - pull_out + t, center_y + dw / 2, t])
      rotate([0, 0, -90])
        drawer_3d();
  }

  // 6. Dice
  if (include_dice) {
    pull_out = drawer_pull_out;
    center_y = 1.5 * sq_y;
    t = material_thickness;
    dw = lengths[11] - 4 * t - 2 * drawer_clearance;

    color("ivory")for (i = [0:num_dice - 1]) {
      // Arrange them in a 2x2 square inside the open drawer
      col = i % 2;
      row = floor(i / 2);

      // Random Z rotation based on index i
      rot_z = rands(0, 360, 1, i + 42)[0];

      // Z is 2*t because the drawer sits at Z=t and its floor is thickness t
      // X is calculated to sit just inside the drawer front wall (-border_width - pull_out + t)
      translate([-border_width - pull_out + t + 15 + col * (dice_edge + 5), center_y - (dice_edge / 2) - 5 + row * (dice_edge + 5), 2 * t])
        rotate([0, 0, rot_z])
          rounded_tetrahedron(edge_length=dice_edge, corner_radius=dice_corner_radius, mark_pos=dice_mark_pos, mark_size=dice_mark_size, center=false);
    }
  }

  // 7. Play Pieces
  if (include_pieces) {
    piece_d = sq_size * piece_ratio;
    piece_h = piece_d * piece_height_ratio;

    // Player 1 pieces
    for (i = [0:ceil(num_pieces / 2) - 1]) {
      translate([i * (piece_d + 5), 3 * sq_y + border_width + 20, 0]) {
        if (piece_type == "3D") {
          color("sienna") ur_piece(piece_d, piece_h);
        } else {
          color("peru") linear_extrude(height=material_thickness) circle(d=piece_d, $fn=64);
          color("darkred") translate([0, 0, material_thickness]) linear_extrude(height=0.02) ur_piece_laser_engraving(piece_d, 1);
        }
      }
    }

    // Player 2 pieces
    for (i = [0:floor(num_pieces / 2) - 1]) {
      translate([i * (piece_d + 5), -border_width - 20 - piece_d, 0]) {
        if (piece_type == "3D") {
          color("navajowhite") ur_piece(piece_d, piece_h);
        } else {
          color("burlywood") linear_extrude(height=material_thickness) circle(d=piece_d, $fn=64);
          color("darkred") translate([0, 0, material_thickness]) linear_extrude(height=0.02) ur_piece_laser_engraving(piece_d, 2);
        }
      }
    }
  }
}

// 2D Laser Cut Pieces Layout
module pieces_layout_2d(mode = "2D") {
  piece_d = sq_size * piece_ratio;
  spacing = piece_d + 5;

  for (i = [0:num_pieces - 1]) {
    row = floor(i / 7);
    col = i % 7;
    translate([col * spacing, row * spacing]) {
      if (mode == "2D") {
        circle(d=piece_d, $fn=64);
      } else if (mode == "2D_ENGRAVE") {
        player = (i < num_pieces / 2) ? 1 : 2;
        ur_piece_laser_engraving(piece_d, player);
      }
    }
  }
}

// --- Output Selection ---
if (output_mode == "3D") {
  assembly_3d();
} else if (output_mode == "2D") {
  offset(r=kerf_offset) {
    // Base Plate
    slotted_plate_shape();

    // Top Plate (shifted to the right)
    translate([board_length + 20, 0]) {
      slotted_plate_shape(flush_top_plate);
    }

    // Side walls (shifted below)
    translate([0, -50]) side_walls_layout("2D");

    // Drawer Parts
    if (include_drawer) {
      translate([board_length + 20, 150]) drawer_parts("2D");
    }

    // 2D Play Pieces
    if (include_pieces) {
      translate([0, 150]) pieces_layout_2d("2D");
    }
  }
} else if (output_mode == "2D_ENGRAVE") {
  // Top Plate (shifted to the right)
  translate([board_length + 20, 0]) {
    engraving_layer();
  }

  // Side walls (shifted below)
  translate([0, -50]) side_walls_layout("2D_ENGRAVE");

  // Drawer Parts
  if (include_drawer) {
    translate([board_length + 20, 150]) drawer_parts("2D_ENGRAVE");
  }

  // 2D Play Pieces
  if (include_pieces) {
    translate([0, 150]) pieces_layout_2d("2D_ENGRAVE");
  }
} else if (output_mode == "DICE") {
  rounded_tetrahedron(edge_length=dice_edge, corner_radius=dice_corner_radius, mark_pos=dice_mark_pos, mark_size=dice_mark_size, center=false);
} else if (output_mode == "PIECE") {
  piece_d = sq_size * piece_ratio;
  piece_h = piece_d * piece_height_ratio;
  ur_piece(piece_d, piece_h);
}
