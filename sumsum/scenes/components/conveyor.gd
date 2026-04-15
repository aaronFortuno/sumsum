class_name Conveyor
extends Node2D

var grid_pos: Vector2i = Vector2i.ZERO
var direction: int = Constants.Direction.RIGHT  # Where items flow TO
var input_direction: int = -1  # Where items come FROM (-1 = auto/opposite)
var is_fixed := false
var anim_offset: float = 0.0  # For belt animation

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
	input_direction = -1
	queue_redraw()

func set_input_direction(from_dir: int) -> void:
	input_direction = from_dir
	queue_redraw()

func get_effective_input_dir() -> int:
	if input_direction >= 0:
		return input_direction
	return Constants.opposite_dir(direction)

func is_corner() -> bool:
	var in_dir := get_effective_input_dir()
	return in_dir != Constants.opposite_dir(direction)

func get_curve_info() -> Dictionary:
	var half := float(Constants.CELL_SIZE) / 2.0
	var in_vec := Vector2(Constants.DIR_VECTORS[get_effective_input_dir()])
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

func _process(delta: float) -> void:
	anim_offset += ANIM_SPEED * delta
	anim_offset = fmod(anim_offset, DASH_LENGTH + DASH_GAP)
	queue_redraw()

func _draw() -> void:
	var half := Constants.CELL_SIZE / 2.0 - MARGIN
	var in_dir := get_effective_input_dir()
	var out_dir := direction

	# Background
	draw_rect(Rect2(-half, -half, half * 2, half * 2), Constants.COLOR_CONVEYOR, true)

	if is_corner():
		_draw_corner(in_dir, out_dir, half)
	else:
		_draw_straight(out_dir, half)

	# Subtle border
	draw_rect(Rect2(-half, -half, half * 2, half * 2), Constants.COLOR_CONVEYOR.lightened(0.1), false, 1.0)

func _draw_straight(dir: int, half: float) -> void:
	var is_horizontal: bool = dir == Constants.Direction.RIGHT or dir == Constants.Direction.LEFT
	var sign_dir: float = 1.0 if (dir == Constants.Direction.RIGHT or dir == Constants.Direction.DOWN) else -1.0

	if is_horizontal:
		# Rails (top and bottom edges of belt)
		var rail_y1 := -BELT_WIDTH / 2.0
		var rail_y2 := BELT_WIDTH / 2.0
		draw_line(Vector2(-half, rail_y1), Vector2(half, rail_y1), Constants.COLOR_CONVEYOR.darkened(0.2), RAIL_WIDTH)
		draw_line(Vector2(-half, rail_y2), Vector2(half, rail_y2), Constants.COLOR_CONVEYOR.darkened(0.2), RAIL_WIDTH)

		# Animated dashes (perpendicular stripes on the belt)
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
		# Vertical belt
		var rail_x1 := -BELT_WIDTH / 2.0
		var rail_x2 := BELT_WIDTH / 2.0
		draw_line(Vector2(rail_x1, -half), Vector2(rail_x1, half), Constants.COLOR_CONVEYOR.darkened(0.2), RAIL_WIDTH)
		draw_line(Vector2(rail_x2, -half), Vector2(rail_x2, half), Constants.COLOR_CONVEYOR.darkened(0.2), RAIL_WIDTH)

		var start_y := -half + fmod(anim_offset * sign_dir, DASH_LENGTH + DASH_GAP)
		if sign_dir < 0:
			start_y = half - fmod(anim_offset, DASH_LENGTH + DASH_GAP)
		var y := start_y - (DASH_LENGTH + DASH_GAP)
		while y < half + DASH_LENGTH:
			var y1 := clampf(y, -half, half)
			var dash_color := Constants.COLOR_CONVEYOR_ARROW
			dash_color.a = 0.5
			draw_line(Vector2(-BELT_WIDTH / 2.0 + 3, y1), Vector2(BELT_WIDTH / 2.0 - 3, y1), dash_color, 1.5)
			y += DASH_LENGTH + DASH_GAP

func _draw_corner(in_dir: int, out_dir: int, half: float) -> void:
	# Pivot = inner corner where entry and exit edges meet
	var in_edge_vec := Vector2(Constants.DIR_VECTORS[in_dir])   # Points toward entry edge
	var out_edge_vec := Vector2(Constants.DIR_VECTORS[out_dir]) # Points toward exit edge
	var pivot := (in_edge_vec + out_edge_vec) * half

	# Compute angles from pivot to entry/exit midpoints
	var entry_point := in_edge_vec * half
	var exit_point := out_edge_vec * half
	var entry_rel := entry_point - pivot
	var exit_rel := exit_point - pivot
	var start_angle := atan2(entry_rel.y, entry_rel.x)
	var end_angle := atan2(exit_rel.y, exit_rel.x)

	# Ensure shortest arc (always 90°)
	var diff := end_angle - start_angle
	if diff > PI:
		end_angle -= TAU
	elif diff < -PI:
		end_angle += TAU

	var mid_r := half
	var inner_r := half - BELT_WIDTH / 2.0
	var outer_r := half + BELT_WIDTH / 2.0

	# Rails
	var rail_color := Constants.COLOR_CONVEYOR.darkened(0.2)
	draw_arc(pivot, inner_r, start_angle, end_angle, 16, rail_color, RAIL_WIDTH)
	draw_arc(pivot, outer_r, start_angle, end_angle, 16, rail_color, RAIL_WIDTH)

	# Animated dashes along the curve (radial = perpendicular to belt flow)
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
		# Radial direction (perpendicular to belt, toward/away from pivot)
		var radial := Vector2(cos(angle), sin(angle))
		var p1 := p + radial * (BELT_WIDTH / 2.0 - 3)
		var p2 := p - radial * (BELT_WIDTH / 2.0 - 3)
		draw_line(p1, p2, dash_color, 1.5)
		pos += total_pattern
