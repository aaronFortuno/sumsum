class_name SplitterBlock
extends Node2D

## A railway switch: distributes incoming balls round-robin
## across its output directions.

var grid_pos: Vector2i = Vector2i.ZERO
var is_fixed := false

## Discovered from neighboring conveyors by GridManager.
var input_side: int = -1  # Side where balls enter
var output_sides: Array[int] = []  # Sides where balls exit

## Round-robin state
var _next_output: int = 0

const MARGIN := 4.0

func setup(p_pos: Vector2i, p_fixed := false) -> void:
	grid_pos = p_pos
	is_fixed = p_fixed
	position = Constants.grid_to_world(grid_pos)
	queue_redraw()

func rotate_cw() -> void:
	queue_redraw()

# --- Connection management (called by GridManager) ---

func update_connections(p_input: int, p_outputs: Array) -> void:
	input_side = p_input
	output_sides.clear()
	for o in p_outputs:
		output_sides.append(o as int)
	queue_redraw()

# --- Round-robin output ---

func peek_next_output() -> int:
	if output_sides.is_empty():
		return -1
	return output_sides[_next_output % output_sides.size()]

func advance_output() -> void:
	if not output_sides.is_empty():
		_next_output = (_next_output + 1) % output_sides.size()
	queue_redraw()

func reset() -> void:
	_next_output = 0

# --- Drawing ---

func _draw() -> void:
	var half := Constants.CELL_SIZE / 2.0 - MARGIN

	# Background (diamond shape)
	var points := PackedVector2Array([
		Vector2(0, -half), Vector2(half, 0),
		Vector2(0, half), Vector2(-half, 0)
	])
	draw_colored_polygon(points, Constants.COLOR_SPLITTER)

	# Border
	for i in range(4):
		draw_line(points[i], points[(i + 1) % 4], Constants.COLOR_SPLITTER_DARK, 2.0, true)

	# Input indicator
	if input_side >= 0:
		var in_vec := Vector2(Constants.DIR_VECTORS[input_side])
		var in_pos := in_vec * (half - 4)
		draw_circle(in_pos, 4.0, Color(1, 1, 1, 0.4))

	# Output arrows (highlight the next one)
	for i in range(output_sides.size()):
		var side: int = output_sides[i]
		var dir_vec := Vector2(Constants.DIR_VECTORS[side])
		var angle: float = Constants.DIR_ANGLES[side]
		var arrow_start := dir_vec * (half - 10)
		var arrow_end := dir_vec * (half + 2)
		var is_active: bool = (i == _next_output % output_sides.size()) if not output_sides.is_empty() else false
		var color: Color = Color.WHITE if is_active else Constants.COLOR_SPLITTER_DARK
		draw_line(arrow_start, arrow_end, color, 3.0 if is_active else 2.0, true)

		# Small arrowhead
		var tip := dir_vec * (half + 2)
		var perp := Vector2(-dir_vec.y, dir_vec.x)
		draw_line(tip, tip - dir_vec * 6 + perp * 4, color, 2.0, true)
		draw_line(tip, tip - dir_vec * 6 - perp * 4, color, 2.0, true)

func _ready() -> void:
	# Symbol label
	var label := Label.new()
	label.name = "SymbolLabel"
	label.text = "⇅"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", Color.WHITE)
	var half := Constants.CELL_SIZE / 2.0 - MARGIN
	label.position = Vector2(-half, -14)
	label.size = Vector2(half * 2, 28)
	add_child(label)
