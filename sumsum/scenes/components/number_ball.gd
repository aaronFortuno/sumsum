class_name NumberBall
extends Node2D

signal arrived(ball: NumberBall, grid_pos: Vector2i)

var value: float = 0.0
var grid_pos: Vector2i = Vector2i.ZERO
var moving := false
var from_direction: int = -1  # Direction the ball came FROM (for operator input)

const FONT_SIZE := 14
const OUTLINE_SIZE := 3

func setup(p_value: float, p_grid_pos: Vector2i, p_from_dir: int = -1) -> void:
	value = p_value
	grid_pos = p_grid_pos
	from_direction = p_from_dir
	position = Constants.grid_to_world(grid_pos)
	queue_redraw()

## Move in a straight line to the center of a cell (for targets, operators).
func move_to(target_grid_pos: Vector2i) -> void:
	if moving:
		return
	moving = true
	_update_from_direction(target_grid_pos - grid_pos)
	grid_pos = target_grid_pos
	var target_world := Constants.grid_to_world(target_grid_pos)
	var tween := create_tween()
	tween.tween_property(self, "position", target_world, Constants.BALL_MOVE_DURATION)\
		.set_trans(Tween.TRANS_LINEAR)
	tween.tween_callback(_on_arrived)

## Move through a conveyor cell, ending at its EXIT EDGE.
## Straight line if arc is empty; follows the conveyor's arc otherwise.
## Each cell is treated individually — exit edge of one = entry edge of next.
func move_to_exit(target_grid_pos: Vector2i, exit_world: Vector2, arc: Dictionary = {}) -> void:
	if moving:
		return
	moving = true
	_update_from_direction(target_grid_pos - grid_pos)
	grid_pos = target_grid_pos

	var speed: float = float(Constants.CELL_SIZE) / Constants.BALL_MOVE_DURATION

	if arc.is_empty():
		# Straight conveyor: go from current position to exit edge
		var dist: float = position.distance_to(exit_world)
		var duration: float = dist / speed if dist > 0.5 else 0.01
		var tween := create_tween()
		tween.tween_property(self, "position", exit_world, duration)\
			.set_trans(Tween.TRANS_LINEAR)
		tween.tween_callback(_on_arrived)
	else:
		# Corner conveyor: approach entry edge, then follow arc to exit edge
		var cell_world: Vector2 = Constants.grid_to_world(target_grid_pos)
		var pivot_local: Vector2 = arc.pivot
		var pivot_world: Vector2 = cell_world + pivot_local
		var r: float = arc.radius
		var sa: float = arc.start_angle
		var ea: float = arc.end_angle

		var start_pos: Vector2 = position
		var entry_point: Vector2 = pivot_world + Vector2(cos(sa), sin(sa)) * r

		var d1: float = start_pos.distance_to(entry_point)
		var d2: float = r * absf(ea - sa)
		var total: float = d1 + d2
		var t1: float = d1 / total if total > 0.5 else 0.0
		var duration: float = total / speed if total > 0.5 else 0.01

		var tween := create_tween()
		tween.tween_method(func(t: float) -> void:
			if t <= t1 and t1 > 0.0:
				# Straight: current position → arc entry edge
				position = start_pos.lerp(entry_point, t / t1)
			else:
				# Arc: entry edge → exit edge
				var arc_t: float = (t - t1) / (1.0 - t1) if (1.0 - t1) > 0.0 else 1.0
				var angle: float = lerpf(sa, ea, arc_t)
				position = pivot_world + Vector2(cos(angle), sin(angle)) * r
		, 0.0, 1.0, duration)
		tween.tween_callback(_on_arrived)

func _update_from_direction(delta: Vector2i) -> void:
	if delta == Vector2i(1, 0):
		from_direction = Constants.Direction.LEFT
	elif delta == Vector2i(-1, 0):
		from_direction = Constants.Direction.RIGHT
	elif delta == Vector2i(0, 1):
		from_direction = Constants.Direction.UP
	elif delta == Vector2i(0, -1):
		from_direction = Constants.Direction.DOWN

func _on_arrived() -> void:
	moving = false
	arrived.emit(self, grid_pos)

func _draw() -> void:
	var text: String = Constants.format_number(value)
	var font: Font = ThemeDB.fallback_font
	var text_size: Vector2 = font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, FONT_SIZE)
	var offset := Vector2(-text_size.x / 2.0, text_size.y / 4.0)

	# Outline (dark, drawn in 8 directions)
	var outline_color := Color(0.05, 0.05, 0.1, 0.9)
	for dx in [-1, 0, 1]:
		for dy in [-1, 0, 1]:
			if dx == 0 and dy == 0:
				continue
			draw_string(font, offset + Vector2(dx, dy) * OUTLINE_SIZE,
				text, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE, outline_color)

	# Main text
	draw_string(font, offset, text, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE, Color.WHITE)

func _process(_delta: float) -> void:
	queue_redraw()

func _ready() -> void:
	z_index = 10
