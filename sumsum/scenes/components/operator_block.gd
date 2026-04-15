class_name OperatorBlock
extends Node2D

signal result_produced(value: float, grid_pos: Vector2i, direction: int)

var grid_pos: Vector2i = Vector2i.ZERO
var op_type: int = Constants.OperatorType.ADD
var direction: int = Constants.Direction.RIGHT  # Output direction
var is_fixed := false

# Input system: operator accepts from the two sides that are NOT the output and NOT opposite output
# For output RIGHT: inputs from TOP and BOTTOM (or LEFT)
# Simplified: input A = opposite of output, input B = clockwise from output
var input_values: Array = [NAN, NAN]
var input_filled: Array = [false, false]

const MARGIN := 4.0

func setup(p_pos: Vector2i, p_op: int, p_dir: int, p_fixed := false) -> void:
	grid_pos = p_pos
	op_type = p_op
	direction = p_dir
	is_fixed = p_fixed
	position = Constants.grid_to_world(grid_pos)
	queue_redraw()

func rotate_cw() -> void:
	direction = Constants.next_direction(direction)
	queue_redraw()

func get_input_directions() -> Array:
	# Input A comes from opposite side, Input B from the clockwise side
	var opposite: int = Constants.opposite_dir(direction)
	var clockwise: int = Constants.next_direction(direction)
	return [opposite, clockwise]

func receive_number(ball_value: float, from_dir: int) -> bool:
	var input_dirs := get_input_directions()
	for i in range(2):
		if from_dir == input_dirs[i] and not input_filled[i]:
			input_values[i] = ball_value
			input_filled[i] = true
			queue_redraw()
			_try_compute()
			return true
	return false

func _try_compute() -> void:
	if not input_filled[0] or not input_filled[1]:
		return
	var a: float = input_values[0]
	var b: float = input_values[1]
	var result: float = 0.0

	match op_type:
		Constants.OperatorType.ADD:
			result = a + b
		Constants.OperatorType.SUBTRACT:
			result = a - b
		Constants.OperatorType.MULTIPLY:
			result = a * b
		Constants.OperatorType.DIVIDE:
			if b != 0:
				result = a / b
			else:
				result = 0  # Handle division by zero gracefully

	# Reset inputs
	input_values = [NAN, NAN]
	input_filled = [false, false]
	queue_redraw()

	# Emit result after a short delay for visual feedback
	await get_tree().create_timer(0.15).timeout
	result_produced.emit(result, grid_pos, direction)

func _draw() -> void:
	var half := Constants.CELL_SIZE / 2.0 - MARGIN
	# Background
	draw_rect(Rect2(-half, -half, half * 2, half * 2), Constants.COLOR_OPERATOR, true)
	# Border
	draw_rect(Rect2(-half, -half, half * 2, half * 2), Constants.COLOR_OPERATOR_DARK, false, 2.0)

	# Draw input indicators
	var input_dirs := get_input_directions()
	for i in range(2):
		var dir_vec := Vector2(Constants.DIR_VECTORS[input_dirs[i]])
		var indicator_pos := dir_vec * (half - 6)
		var color := Color(0.9, 0.9, 0.2) if input_filled[i] else Color(1, 1, 1, 0.3)
		draw_circle(indicator_pos, 5.0, color)

	# Output arrow
	var angle: float = Constants.DIR_ANGLES[direction]
	var arrow_start := Vector2(cos(angle), sin(angle)) * (half - 8)
	var arrow_end := Vector2(cos(angle), sin(angle)) * (half + 2)
	draw_line(arrow_start, arrow_end, Constants.COLOR_OPERATOR_DARK, 3.0, true)

func _ready() -> void:
	# Operator symbol label
	var label := Label.new()
	label.name = "SymbolLabel"
	label.text = Constants.OP_SYMBOLS[op_type]
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 28)
	label.add_theme_color_override("font_color", Color.WHITE)
	var half := Constants.CELL_SIZE / 2.0 - MARGIN
	label.position = Vector2(-half, -16)
	label.size = Vector2(half * 2, 32)
	add_child(label)
