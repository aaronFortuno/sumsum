class_name Conveyor
extends Node2D

var grid_pos: Vector2i = Vector2i.ZERO
var direction: int = Constants.Direction.RIGHT  # Where items flow TO
var input_directions: Array[int] = []  # All sides that feed INTO this conveyor
var is_fixed := false
var is_crossing := false  # Two perpendicular flows crossing independently
var anim_offset: float = 0.0  # For belt animation

## Per-instance tunable (upgradeable in the future)
var speed_factor: float = 1.0

const MARGIN := 4.0
const RAIL_WIDTH := 4.0
const BELT_WIDTH := 28.0
const DASH_LENGTH := 12.0
const DASH_GAP := 10.0
const ANIM_SPEED := 60.0  # Pixels per second

func setup(p_pos: Vector2i, p_dir: int, p_fixed := false) -> void:
	grid_pos = p_pos
	direction = p_dir
	is_fixed = p_fixed
	position = Constants.grid_to_world(grid_pos)
	queue_redraw()

func rotate_cw() -> void:
	direction = Constants.next_direction(direction)
	queue_redraw()

# --- Input management ---

func add_input_direction(from_dir: int) -> void:
	if from_dir not in input_directions:
		input_directions.append(from_dir)
	queue_redraw()

func clear_input_directions() -> void:
	input_directions.clear()
	queue_redraw()

## Backward-compat: set a single input (used by drag preview).
func set_input_direction(from_dir: int) -> void:
	input_directions = [from_dir]
	queue_redraw()

func get_effective_input_dir() -> int:
	if input_directions.size() > 0:
		return input_directions[0]
	return Constants.opposite_dir(direction)

func is_merge() -> bool:
	return input_directions.size() > 1

# --- Output / corner / curve queries ---

## Returns the output direction for a ball entering from [entry_side].
## Normal/merge conveyors always output toward [direction].
## Crossings route each ball straight through: output = opposite of entry.
func get_output_for(entry_side: int) -> int:
	if is_crossing:
		return Constants.opposite_dir(entry_side)
	return direction

func is_corner() -> bool:
	return is_corner_for(get_effective_input_dir())

func is_corner_for(entry_side: int) -> bool:
	if is_crossing:
		return false  # Crossings are always straight-through
	return entry_side != Constants.opposite_dir(direction)

func get_curve_info() -> Dictionary:
	return get_curve_info_for(get_effective_input_dir())

func get_curve_info_for(entry_side: int) -> Dictionary:
	var half := float(Constants.CELL_SIZE) / 2.0
	var in_vec := Vector2(Constants.DIR_VECTORS[entry_side])
	var out_vec := Vector2(Constants.DIR_VECTORS[direction])
	var pivot := (in_vec + out_vec) * half
	var entry_rel := in_vec * half - pivot
	var exit_rel := out_vec * half - pivot
	var sa := atan2(entry_rel.y, entry_rel.x)
	var ea := atan2(exit_rel.y, exit_rel.x)
	var diff := ea - sa
	if diff > PI: ea -= TAU
	elif diff < -PI: ea += TAU
	return {"pivot": pivot, "radius": half, "start_angle": sa, "end_angle": ea}

# --- Animation ---

func _process(delta: float) -> void:
	anim_offset += ANIM_SPEED * delta
	anim_offset = fmod(anim_offset, DASH_LENGTH + DASH_GAP)
	queue_redraw()

# --- Drawing ---

func _draw() -> void:
	var half := Constants.CELL_SIZE / 2.0 - MARGIN
	var out_dir := direction

	# Background
	draw_rect(Rect2(-half, -half, half * 2, half * 2), Constants.COLOR_CONVEYOR, true)

	if is_crossing:
		_draw_crossing(half)
	elif is_merge():
		_draw_merge(half)
	elif is_corner():
		_draw_corner(get_effective_input_dir(), out_dir, half)
	else:
		_draw_straight(out_dir, half)

	# Subtle border
	draw_rect(Rect2(-half, -half, half * 2, half * 2), Constants.COLOR_CONVEYOR.lightened(0.1), false, 1.0)

func _draw_crossing(half: float) -> void:
	# Determine actual flow directions from inputs
	var h_dir: int = -1
	var v_dir: int = -1
	for in_dir in input_directions:
		var out_dir: int = Constants.opposite_dir(in_dir)
		if out_dir == Constants.Direction.RIGHT or out_dir == Constants.Direction.LEFT:
			if h_dir < 0: h_dir = out_dir
		else:
			if v_dir < 0: v_dir = out_dir
	# Fallback if an axis has no input yet
	if h_dir < 0:
		var is_h: bool = direction == Constants.Direction.RIGHT or direction == Constants.Direction.LEFT
		h_dir = direction if is_h else Constants.Direction.RIGHT
	if v_dir < 0:
		var is_v: bool = direction == Constants.Direction.DOWN or direction == Constants.Direction.UP
		v_dir = direction if is_v else Constants.Direction.DOWN
	_draw_straight(h_dir, half)
	_draw_straight(v_dir, half)

func _draw_merge(half: float) -> void:
	# Draw each input→output path
	for in_dir in input_directions:
		if in_dir == Constants.opposite_dir(direction):
			_draw_straight(direction, half)
		else:
			_draw_corner(in_dir, direction, half)

func _draw_straight(dir: int, half: float) -> void:
	var is_horizontal: bool = dir == Constants.Direction.RIGHT or dir == Constants.Direction.LEFT
	var sign_dir: float = 1.0 if (dir == Constants.Direction.RIGHT or dir == Constants.Direction.DOWN) else -1.0

	if is_horizontal:
		var rail_y1 := -BELT_WIDTH / 2.0
		var rail_y2 := BELT_WIDTH / 2.0
		draw_line(Vector2(-half, rail_y1), Vector2(half, rail_y1), Constants.COLOR_CONVEYOR.darkened(0.2), RAIL_WIDTH)
		draw_line(Vector2(-half, rail_y2), Vector2(half, rail_y2), Constants.COLOR_CONVEYOR.darkened(0.2), RAIL_WIDTH)

		var start_x := -half + fmod(anim_offset * sign_dir, DASH_LENGTH + DASH_GAP)
		if sign_dir < 0:
			start_x = half - fmod(anim_offset, DASH_LENGTH + DASH_GAP)
		var x := start_x - (DASH_LENGTH + DASH_GAP)
		while x < half + DASH_LENGTH:
			var x1 := clampf(x, -half, half)
			var dash_color := Constants.COLOR_CONVEYOR_ARROW
			dash_color.a = 0.5
			draw_line(Vector2(x1, -BELT_WIDTH / 2.0 + 3), Vector2(x1, BELT_WIDTH / 2.0 - 3), dash_color, 1.5)
			x += DASH_LENGTH + DASH_GAP
	else:
		var rail_x1 := -BELT_WIDTH / 2.0
		var rail_x2 := BELT_WIDTH / 2.0
		draw_line(Vector2(rail_x1, -half), Vector2(rail_x1, half), Constants.COLOR_CONVEYOR.darkened(0.2), RAIL_WIDTH)
		draw_line(Vector2(rail_x2, -half), Vector2(rail_x2, half), Constants.COLOR_CONVEYOR.darkened(0.2), RAIL_WIDTH)

		var sign_v: float = 1.0 if dir == Constants.Direction.DOWN else -1.0
		var start_y := -half + fmod(anim_offset * sign_v, DASH_LENGTH + DASH_GAP)
		if sign_v < 0:
			start_y = half - fmod(anim_offset, DASH_LENGTH + DASH_GAP)
		var y := start_y - (DASH_LENGTH + DASH_GAP)
		while y < half + DASH_LENGTH:
			var y1 := clampf(y, -half, half)
			var dash_color := Constants.COLOR_CONVEYOR_ARROW
			dash_color.a = 0.5
			draw_line(Vector2(-BELT_WIDTH / 2.0 + 3, y1), Vector2(BELT_WIDTH / 2.0 - 3, y1), dash_color, 1.5)
			y += DASH_LENGTH + DASH_GAP

func _draw_corner(in_dir: int, out_dir: int, half: float) -> void:
	var in_edge_vec := Vector2(Constants.DIR_VECTORS[in_dir])
	var out_edge_vec := Vector2(Constants.DIR_VECTORS[out_dir])
	var pivot := (in_edge_vec + out_edge_vec) * half

	var entry_point := in_edge_vec * half
	var exit_point := out_edge_vec * half
	var entry_rel := entry_point - pivot
	var exit_rel := exit_point - pivot
	var start_angle := atan2(entry_rel.y, entry_rel.x)
	var end_angle := atan2(exit_rel.y, exit_rel.x)

	var diff := end_angle - start_angle
	if diff > PI:
		end_angle -= TAU
	elif diff < -PI:
		end_angle += TAU

	var mid_r := half
	var inner_r := half - BELT_WIDTH / 2.0
	var outer_r := half + BELT_WIDTH / 2.0

	var rail_color := Constants.COLOR_CONVEYOR.darkened(0.2)
	draw_arc(pivot, inner_r, start_angle, end_angle, 16, rail_color, RAIL_WIDTH)
	draw_arc(pivot, outer_r, start_angle, end_angle, 16, rail_color, RAIL_WIDTH)

	var dash_color := Constants.COLOR_CONVEYOR_ARROW
	dash_color.a = 0.5
	var arc_length: float = mid_r * absf(end_angle - start_angle)
	var total_pattern := DASH_LENGTH + DASH_GAP
	var offset_along := fmod(anim_offset, total_pattern)
	var pos := -total_pattern + offset_along

	while pos < arc_length + total_pattern:
		var t := clampf(pos / arc_length, 0.0, 1.0)
		var angle: float = lerpf(start_angle, end_angle, t)
		var p := pivot + Vector2(cos(angle), sin(angle)) * mid_r
		var radial := Vector2(cos(angle), sin(angle))
		var p1 := p + radial * (BELT_WIDTH / 2.0 - 3)
		var p2 := p - radial * (BELT_WIDTH / 2.0 - 3)
		draw_line(p1, p2, dash_color, 1.5)
		pos += total_pattern
