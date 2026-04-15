class_name Conveyor
extends Node2D

var grid_pos: Vector2i = Vector2i.ZERO
var direction: int = Constants.Direction.RIGHT  # Primary output direction
var input_directions: Array[int] = []  # All sides that feed INTO this conveyor
var output_directions: Array[int] = []  # Extra outputs for splitter (empty = use direction only)
var is_fixed := false
var is_crossing := false  # Two perpendicular flows crossing independently
var anim_offset: float = 0.0  # For belt animation

## Per-instance tunable (upgradeable in the future)
var speed_factor: float = 1.0

## Round-robin state for splitter
var _next_output: int = 0

const RAIL_WIDTH := 3.0
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

func set_input_direction(from_dir: int) -> void:
	input_directions = [from_dir]
	queue_redraw()

func get_effective_input_dir() -> int:
	if input_directions.size() > 0:
		return input_directions[0]
	return Constants.opposite_dir(direction)

func is_merge() -> bool:
	return input_directions.size() > 1

# --- Splitter (multiple outputs) ---

func is_splitter() -> bool:
	return output_directions.size() > 1

func add_output_direction(dir: int) -> void:
	if output_directions.is_empty():
		output_directions = [direction]  # Include primary
	if dir not in output_directions:
		output_directions.append(dir)
	queue_redraw()

func clear_split() -> void:
	output_directions.clear()
	_next_output = 0
	queue_redraw()

func get_all_outputs() -> Array[int]:
	if output_directions.size() > 0:
		return output_directions
	return [direction]

func peek_next_output() -> int:
	var outs := get_all_outputs()
	return outs[_next_output % outs.size()]

func advance_output() -> void:
	var outs := get_all_outputs()
	if outs.size() > 0:
		_next_output = (_next_output + 1) % outs.size()
	queue_redraw()

# --- Output / corner / curve queries ---

func get_output_for(entry_side: int) -> int:
	if is_crossing:
		return Constants.opposite_dir(entry_side)
	return direction

func is_corner() -> bool:
	return is_corner_for(get_effective_input_dir())

func is_corner_for(entry_side: int) -> bool:
	if is_crossing:
		return false
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
	var half := Constants.CELL_SIZE / 2.0  # Full cell half — no margin, seamless

	if is_crossing:
		_draw_crossing(half)
	elif is_splitter():
		_draw_splitter(half)
	elif is_merge():
		_draw_merge(half)
	elif is_corner():
		_draw_corner(get_effective_input_dir(), direction, half)
	else:
		_draw_straight(direction, half)

func _draw_crossing(half: float) -> void:
	var h_dir: int = -1
	var v_dir: int = -1
	for in_dir in input_directions:
		var out_dir: int = Constants.opposite_dir(in_dir)
		if out_dir == Constants.Direction.RIGHT or out_dir == Constants.Direction.LEFT:
			if h_dir < 0: h_dir = out_dir
		else:
			if v_dir < 0: v_dir = out_dir
	if h_dir < 0:
		var is_h: bool = direction == Constants.Direction.RIGHT or direction == Constants.Direction.LEFT
		h_dir = direction if is_h else Constants.Direction.RIGHT
	if v_dir < 0:
		var is_v: bool = direction == Constants.Direction.DOWN or direction == Constants.Direction.UP
		v_dir = direction if is_v else Constants.Direction.DOWN
	_draw_straight(h_dir, half)
	_draw_straight(v_dir, half)

func _draw_splitter(half: float) -> void:
	# Draw each input→output path (one input, multiple outputs)
	var in_dir: int = get_effective_input_dir()
	for out_dir in output_directions:
		if in_dir == Constants.opposite_dir(out_dir):
			_draw_straight(out_dir, half)
		else:
			_draw_corner(in_dir, out_dir, half)

func _draw_merge(half: float) -> void:
	for in_dir in input_directions:
		if in_dir == Constants.opposite_dir(direction):
			_draw_straight(direction, half)
		else:
			_draw_corner(in_dir, direction, half)

func _draw_straight(dir: int, half: float) -> void:
	var is_horizontal: bool = dir == Constants.Direction.RIGHT or dir == Constants.Direction.LEFT
	var sign_dir: float = 1.0 if (dir == Constants.Direction.RIGHT or dir == Constants.Direction.DOWN) else -1.0
	var rail_color := Constants.COLOR_CONVEYOR.darkened(0.15)
	var belt_color := Constants.COLOR_CONVEYOR

	if is_horizontal:
		# Belt body
		draw_rect(Rect2(-half, -BELT_WIDTH / 2.0, half * 2, BELT_WIDTH), belt_color, true)
		# Rails
		draw_line(Vector2(-half, -BELT_WIDTH / 2.0), Vector2(half, -BELT_WIDTH / 2.0), rail_color, RAIL_WIDTH)
		draw_line(Vector2(-half, BELT_WIDTH / 2.0), Vector2(half, BELT_WIDTH / 2.0), rail_color, RAIL_WIDTH)
		# Animated dashes
		var start_x := -half + fmod(anim_offset * sign_dir, DASH_LENGTH + DASH_GAP)
		if sign_dir < 0:
			start_x = half - fmod(anim_offset, DASH_LENGTH + DASH_GAP)
		var x := start_x - (DASH_LENGTH + DASH_GAP)
		var dash_color := Constants.COLOR_CONVEYOR_ARROW
		dash_color.a = 0.5
		while x < half + DASH_LENGTH:
			var x1 := clampf(x, -half, half)
			draw_line(Vector2(x1, -BELT_WIDTH / 2.0 + 3), Vector2(x1, BELT_WIDTH / 2.0 - 3), dash_color, 1.5)
			x += DASH_LENGTH + DASH_GAP
	else:
		# Belt body
		draw_rect(Rect2(-BELT_WIDTH / 2.0, -half, BELT_WIDTH, half * 2), belt_color, true)
		# Rails
		draw_line(Vector2(-BELT_WIDTH / 2.0, -half), Vector2(-BELT_WIDTH / 2.0, half), rail_color, RAIL_WIDTH)
		draw_line(Vector2(BELT_WIDTH / 2.0, -half), Vector2(BELT_WIDTH / 2.0, half), rail_color, RAIL_WIDTH)
		# Animated dashes
		var sign_v: float = 1.0 if dir == Constants.Direction.DOWN else -1.0
		var start_y := -half + fmod(anim_offset * sign_v, DASH_LENGTH + DASH_GAP)
		if sign_v < 0:
			start_y = half - fmod(anim_offset, DASH_LENGTH + DASH_GAP)
		var y := start_y - (DASH_LENGTH + DASH_GAP)
		var dash_color := Constants.COLOR_CONVEYOR_ARROW
		dash_color.a = 0.5
		while y < half + DASH_LENGTH:
			var y1 := clampf(y, -half, half)
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
	var rail_color := Constants.COLOR_CONVEYOR.darkened(0.15)

	# Belt body (thick arc)
	draw_arc(pivot, mid_r, start_angle, end_angle, 24, Constants.COLOR_CONVEYOR, BELT_WIDTH)
	# Rails
	draw_arc(pivot, inner_r, start_angle, end_angle, 20, rail_color, RAIL_WIDTH)
	draw_arc(pivot, outer_r, start_angle, end_angle, 20, rail_color, RAIL_WIDTH)

	# Animated dashes
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
