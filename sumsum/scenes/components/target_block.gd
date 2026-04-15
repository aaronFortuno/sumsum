class_name TargetBlock
extends Node2D

signal target_reached(target: TargetBlock, value: float, is_correct: bool)

var grid_pos: Vector2i = Vector2i.ZERO
var target_value: float = 0.0
var is_satisfied := false
var is_fixed := true
var last_received: float = NAN
var flash_timer: float = 0.0

const MARGIN := 4.0

func setup(p_pos: Vector2i, p_value: float) -> void:
	grid_pos = p_pos
	target_value = p_value
	position = Constants.grid_to_world(grid_pos)
	if has_node("TargetLabel"):
		get_node("TargetLabel").text = Constants.format_number(target_value)
	queue_redraw()

func receive_number(ball_value: float) -> void:
	last_received = ball_value
	var correct := is_equal_approx(ball_value, target_value)
	if correct:
		is_satisfied = true
		flash_timer = 1.0
	else:
		flash_timer = 0.6
	target_reached.emit(self, ball_value, correct)
	queue_redraw()

func _process(delta: float) -> void:
	if flash_timer > 0:
		flash_timer -= delta
		queue_redraw()

func _draw() -> void:
	var half := Constants.CELL_SIZE / 2.0 - MARGIN
	var base_color: Color = Constants.COLOR_TARGET_OK if is_satisfied else Constants.COLOR_TARGET

	# Flash effect
	if flash_timer > 0 and not is_satisfied:
		base_color = base_color.lerp(Color.RED, flash_timer)

	# Hexagon-ish shape (rounded rect for now)
	draw_rect(Rect2(-half, -half, half * 2, half * 2), base_color, true)
	# Inner border
	var inner := half - 6
	draw_rect(Rect2(-inner, -inner, inner * 2, inner * 2), base_color.darkened(0.25), false, 2.0)
	# Outer border
	draw_rect(Rect2(-half, -half, half * 2, half * 2), base_color.darkened(0.3), false, 2.0)

	# Checkmark if satisfied
	if is_satisfied:
		var check_points := PackedVector2Array([
			Vector2(-8, 2), Vector2(-2, 8), Vector2(10, -6)
		])
		for i in range(check_points.size() - 1):
			draw_line(
				check_points[i] + Vector2(0, 12),
				check_points[i + 1] + Vector2(0, 12),
				Color.WHITE, 3.0, true
			)

func _ready() -> void:
	# Target value label
	var label := Label.new()
	label.name = "TargetLabel"
	label.text = Constants.format_number(target_value)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_color", Color.WHITE)
	var half := Constants.CELL_SIZE / 2.0 - MARGIN
	label.position = Vector2(-half, -18)
	label.size = Vector2(half * 2, 28)
	add_child(label)

	# "Target" small label
	var title := Label.new()
	title.name = "TitleLabel"
	title.text = "="
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 14)
	title.add_theme_color_override("font_color", Color(1, 1, 1, 0.6))
	title.position = Vector2(-half, -half + 2)
	title.size = Vector2(half * 2, 16)
	add_child(title)
