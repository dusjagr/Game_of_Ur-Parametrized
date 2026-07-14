// Royal Game of Ur - Cinematic Deployment Animation
// Render with View -> Animate (Time: 0 to 1, FPS: 30, Steps: 200)

// Include all modules and variables from the main box logic
include <ur_laser_box.scad>

// Suppress the static output of the main file
output_mode = "ANIMATION";
include_drawer = false;
include_dice = false;
include_pieces = false;

// --- Animation Math ---
time = $t; // $t goes from 0.0 to 1.0

// Interpolation and easing helpers
function clamp(val, min_v, max_v) = min(max(val, min_v), max_v);
function lerp(a, b, t) = a + (b - a) * clamp(t, 0, 1);
function ease_in_out(t) = t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t;

// Timeline phases
t_drawer_open = clamp((time - 0.00) / 0.10, 0, 1);
t_drawer_close= clamp((time - 0.50) / 0.10, 0, 1);

// Calculate animated drawer position
anim_pull_out = lerp(0, drawer_pull_out, ease_in_out(t_drawer_open)) - 
                lerp(0, drawer_pull_out, ease_in_out(t_drawer_close));

// --- Gameplay Helper Functions ---
// Field 1-4 are on the 3x4 block. Players enter at field 1 (far left, i=0) and move right towards the bridge (field 5, i=4).
visual_offset_x = -5.0; // Corrected offset to perfectly center pieces on the DXF's internal grid
visual_offset_y = -5.0;

function get_board_x(field) = 
    (field <= 4 ? border_width + (field - 1) * sq_size + sq_size/2 : 
                  border_width + (field - 5) * sq_size + sq_size/2) + visual_offset_x;

// Player 1 (Sienna) starts on the top row (j=2). Player 2 (NavajoWhite) starts on the bottom row (j=0).
function get_board_y(player, field) = 
    (field <= 4 ? border_width + (player==1 ? 2 : 0) * sq_size + sq_size/2 :
                  border_width + 1 * sq_size + sq_size/2) + visual_offset_y;

// --- 1. Render Static Box ---
assembly_3d();

// --- 2. Render Animated Drawer ---
center_y = 1.5 * sq_y;
t_mat = material_thickness;
dw = lengths[11] - 4 * t_mat - 2 * drawer_clearance;

translate([-border_width - anim_pull_out + t_mat, center_y + dw / 2, t_mat])
  rotate([0, 0, -90])
    drawer_3d();

// --- 3. Render Animated Dice ---
for (i = [0:num_dice - 1]) {
  col = i % 2;
  row = floor(i / 2);
  
  // Start position (inside the moving drawer, tracking its pull out)
  start_x = -border_width - anim_pull_out + t_mat + 15 + col * (dice_edge + 5);
  start_y = center_y - (dice_edge/2) - 5 + row * (dice_edge + 5);
  start_z = 2 * t_mat;
  
  // End position (neatly arranged near the drawer on the floor, moved further out)
  end_x = -border_width - drawer_pull_out + t_mat + 15 + col * (dice_edge + 5);
  end_y = center_y - dw/2 - 50 + row * (dice_edge + 5);
  end_z = 0;
  
  // Faster, staggered deployment
  stagger = i * 0.02;
  fly_t = ease_in_out(clamp((time - (0.10 + stagger)) / 0.20, 0, 1));
  
  // Sine wave jump
  hop_z = sin(fly_t * 180) * 80; 
  
  cur_x = lerp(start_x, end_x, fly_t);
  cur_y = lerp(start_y, end_y, fly_t);
  cur_z = lerp(start_z, end_z, fly_t) + hop_z;
  
  // Spin while flying
  final_rot = rands(0, 360, 1, i + 42)[0];
  spin = fly_t * 360 * 2; // Two full spins
  
  translate([cur_x, cur_y, cur_z])
    rotate([0, 0, final_rot + spin])
      rounded_tetrahedron(edge_length=dice_edge, corner_radius=dice_corner_radius, mark_pos=dice_mark_pos, center=false);
}

// --- 4. Render Animated Pieces ---
piece_d = sq_size * piece_ratio;
piece_h = piece_d * piece_height_ratio;

// Player 1 Pieces
color("sienna")
for (i = [0:ceil(num_pieces / 2) - 1]) {
  // Start packed inside the drawer, moving with it
  col = i % 4;
  row = floor(i / 4);
  start_x = -border_width - anim_pull_out + t_mat + 50 + col * (piece_d + 2);
  start_y = center_y + 5 + row * (piece_d + 2);
  start_z = 2 * t_mat;
  
  // End position (classic board edge layout)
  end_x = i * (piece_d + 5);
  end_y = 3 * sq_y + border_width + 20;
  end_z = 0;
  
  // Faster deployment
  stagger = i * 0.02;
  fly_t = ease_in_out(clamp((time - (0.10 + stagger)) / 0.20, 0, 1));
  hop_z = sin(fly_t * 180) * 100;
  
  // Gameplay phase
  is_play = (i <= 2 && time >= 0.60);
  p1_fields = [4, 2, 1, 0, 0, 0, 0, 0, 0];
  play_stagger = i * 0.08;
  play_t = ease_in_out(clamp((time - (0.60 + play_stagger)) / 0.15, 0, 1));
  
  board_x = get_board_x(p1_fields[i]);
  board_y = get_board_y(1, p1_fields[i]);
  board_z = box_height + t_mat * 2 + 0.5;
  hop_play = sin(play_t * 180) * 40;
  
  cur_x = is_play ? lerp(end_x, board_x, play_t) : lerp(start_x, end_x, fly_t);
  cur_y = is_play ? lerp(end_y, board_y, play_t) : lerp(start_y, end_y, fly_t);
  cur_z = is_play ? lerp(end_z, board_z, play_t) + hop_play : lerp(start_z, end_z, fly_t) + hop_z;
  
  translate([cur_x, cur_y, cur_z])
    ur_piece(piece_d, piece_h);
}

// Player 2 Pieces
color("navajowhite")
for (i = [0:floor(num_pieces / 2) - 1]) {
  // Start packed inside the drawer, moving with it
  col = i % 4;
  row = floor(i / 4);
  start_x = -border_width - anim_pull_out + t_mat + 50 + col * (piece_d + 2);
  start_y = center_y - dw/2 + 5 + row * (piece_d + 2);
  start_z = 2 * t_mat;
  
  // End position (classic board edge layout)
  end_x = i * (piece_d + 5);
  end_y = -border_width - 20 - piece_d;
  end_z = 0;
  
  // Faster deployment
  stagger = i * 0.02;
  fly_t = ease_in_out(clamp((time - (0.10 + stagger)) / 0.20, 0, 1));
  hop_z = sin(fly_t * 180) * 100;
  
  // Gameplay phase
  is_play = (i <= 2 && time >= 0.60);
  p2_fields = [3, 2, 1, 0, 0, 0, 0, 0, 0];
  play_stagger = i * 0.08 + 0.04; // Player 2 takes their turn slightly offset from Player 1
  play_t = ease_in_out(clamp((time - (0.60 + play_stagger)) / 0.15, 0, 1));
  
  board_x = get_board_x(p2_fields[i]);
  board_y = get_board_y(2, p2_fields[i]);
  board_z = box_height + t_mat * 2 + 0.5;
  hop_play = sin(play_t * 180) * 40;
  
  cur_x = is_play ? lerp(end_x, board_x, play_t) : lerp(start_x, end_x, fly_t);
  cur_y = is_play ? lerp(end_y, board_y, play_t) : lerp(start_y, end_y, fly_t);
  cur_z = is_play ? lerp(end_z, board_z, play_t) + hop_play : lerp(start_z, end_z, fly_t) + hop_z;
  
  translate([cur_x, cur_y, cur_z])
    ur_piece(piece_d, piece_h);
}
