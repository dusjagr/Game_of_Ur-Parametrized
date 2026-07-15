#!/bin/bash
# Export assets for a given preset in ur_laser_box.json

PRESET=$1

if [ -z "$PRESET" ]; then
    echo "Available presets in ur_laser_box.json:"
    
    # Extract the preset names into an array
    mapfile -t PRESETS < <(grep -E '^[ \t]+"[^"]+": \{' ur_laser_box.json | sed -E 's/^[ \t]+"([^"]+)": \{/\1/')
    
    if [ ${#PRESETS[@]} -eq 0 ]; then
        echo "No presets found!"
        exit 1
    fi

    PS3="Enter the number of the preset to export: "
    select PRESET in "${PRESETS[@]}"; do
        if [ -n "$PRESET" ]; then
            break
        else
            echo "Invalid selection. Try again."
        fi
    done
fi
SCAD_FILE="ur_laser_box.scad"
JSON_FILE="ur_laser_box.json"

if [ ! -f "$JSON_FILE" ]; then
    echo "Error: $JSON_FILE not found."
    exit 1
fi

OUT_DIR="exports/${PRESET}"
mkdir -p "$OUT_DIR"

echo "Exporting preset: $PRESET to $OUT_DIR"

TMP_JSON=".tmp_preset.json"

echo "1/5 Exporting 2D Box Layout (SVG)..."
sed -E 's/"output_mode": "[^"]*"/"output_mode": "2D"/g' "$JSON_FILE" > "$TMP_JSON"
openscad -o "$OUT_DIR/box_layout.svg" -p "$TMP_JSON" -P "$PRESET" "$SCAD_FILE"

echo "2/5 Exporting 2D Engravings (SVG)..."
sed -E 's/"output_mode": "[^"]*"/"output_mode": "2D_ENGRAVE"/g' "$JSON_FILE" > "$TMP_JSON"
openscad -o "$OUT_DIR/engravings.svg" -p "$TMP_JSON" -P "$PRESET" "$SCAD_FILE"

echo "3/5 Exporting Pieces (STL)..."
sed -E 's/"output_mode": "[^"]*"/"output_mode": "PIECE"/g' "$JSON_FILE" > "$TMP_JSON"
openscad -o "$OUT_DIR/pieces.stl" -p "$TMP_JSON" -P "$PRESET" "$SCAD_FILE"

echo "4/6 Exporting Standard Dice (STL)..."
sed -E 's/"output_mode": "[^"]*"/"output_mode": "DICE"/g; s/"dice_style": "[^"]*"/"dice_style": "STANDARD"/g' "$JSON_FILE" > "$TMP_JSON"
openscad -o "$OUT_DIR/dice_standard.stl" -p "$TMP_JSON" -P "$PRESET" "$SCAD_FILE"

echo "5/6 Exporting Cut-Tips Dice Base (STL)..."
sed -E 's/"output_mode": "[^"]*"/"output_mode": "DICE"/g; s/"dice_style": "[^"]*"/"dice_style": "CUT_TIPS"/g' "$JSON_FILE" > "$TMP_JSON"
openscad -o "$OUT_DIR/dice_cut_base.stl" -p "$TMP_JSON" -P "$PRESET" "$SCAD_FILE"

echo "6/6 Exporting Dice Tips (STL)..."
sed -E 's/"output_mode": "[^"]*"/"output_mode": "DICE_TIPS"/g; s/"dice_style": "[^"]*"/"dice_style": "CUT_TIPS"/g' "$JSON_FILE" > "$TMP_JSON"
openscad -o "$OUT_DIR/dice_cut_tips.stl" -p "$TMP_JSON" -P "$PRESET" "$SCAD_FILE"

rm -f "$TMP_JSON"

echo "Merging SVGs into a single layered file..."
cat << 'EOF' > "$OUT_DIR/merge_svgs.py"
import xml.etree.ElementTree as ET
import sys

ET.register_namespace('', "http://www.w3.org/2000/svg")
cut_tree = ET.parse(sys.argv[1])
engrave_tree = ET.parse(sys.argv[2])

cut_root = cut_tree.getroot()
engrave_root = engrave_tree.getroot()

def strip_styles(elem):
    for attr in ['fill', 'stroke', 'stroke-width', 'color']:
        if attr in elem.attrib:
            del elem.attrib[attr]
    for child in elem:
        strip_styles(child)

# Create cut layer (red lines)
cut_g = ET.Element('g', {'id': 'CutLayer', 'stroke': 'red', 'fill': 'none', 'stroke-width': '0.5'})
for child in list(cut_root):
    tag = child.tag.split('}')[-1] if '}' in child.tag else child.tag
    if tag in ['g', 'path', 'polygon', 'rect', 'circle']:
        strip_styles(child)
        cut_g.append(child)
        cut_root.remove(child)

# Create engrave layer (black fill)
engrave_g = ET.Element('g', {'id': 'EngraveLayer', 'fill': 'black', 'stroke': 'none'})
for child in list(engrave_root):
    tag = child.tag.split('}')[-1] if '}' in child.tag else child.tag
    if tag in ['g', 'path', 'polygon', 'rect', 'circle']:
        strip_styles(child)
        engrave_g.append(child)

cut_root.append(cut_g)
cut_root.append(engrave_g)

# Compute unified bounding box
def get_vb(root):
    if 'viewBox' in root.attrib:
        return [float(x) for x in root.attrib['viewBox'].split()]
    return [0,0,0,0]

vb1 = get_vb(cut_root)
vb2 = get_vb(engrave_root)
min_x = min(vb1[0], vb2[0])
min_y = min(vb1[1], vb2[1])
max_x = max(vb1[0]+vb1[2], vb2[0]+vb2[2])
max_y = max(vb1[1]+vb1[3], vb2[1]+vb2[3])

cut_root.attrib['viewBox'] = f"{min_x} {min_y} {max_x - min_x} {max_y - min_y}"
cut_root.attrib['width'] = f"{max_x - min_x}mm"
cut_root.attrib['height'] = f"{max_y - min_y}mm"

cut_tree.write(sys.argv[3], encoding='utf-8', xml_declaration=True)
EOF

python3 "$OUT_DIR/merge_svgs.py" "$OUT_DIR/box_layout.svg" "$OUT_DIR/engravings.svg" "$OUT_DIR/combined_laser_file.svg"
rm -f "$OUT_DIR/merge_svgs.py"

echo "Done! All files exported to $OUT_DIR/"
