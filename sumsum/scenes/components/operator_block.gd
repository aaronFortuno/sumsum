class_name OperatorBlock
extends Node2D

signal result_produced(value: float, grid_pos: Vector2i, direction: int)

var grid_pos: Vector2i = Vector2i.ZERO
var op_type: int = Constants.OperatorType.ADD
var direction: int = Constants.Direction.RIGHT  # Output direction
var is_fixed := false

## Dynamic input slots — keyed by side (Direction), discovered from conveyors.
## Each entry: { "value": float, "filled": bool }
var input_slots: Dictionary = {}

## Per-instance tunables (upgradeable in the future)
var process_delay: float = 0.15

const MARGIN := 4.0

func setup(p_pos: Vector2i, p_op: int, p_dir: int, p_fixed := false) -> void:
	grid_pos = p_pos
	op_type = p_op
	direction = p_dir
	is_fixed = p_fixed
	position = Constants.grid_to_world(grid_pos)
	_setup_symbol_label()
	queue_redraw()

func rotate_cw() -> void:
	direction = Constants.next_direction(direction)
	queue_redraw()

# --- Connection management (called by GridManager) ---

## Rebuild input slots from the list of sides that have conveyors pointing in.
func update_input_connections(input_sides: Array) -> void:
	var old_slots: Dictionary = input_slots.duplicate(true)
	input_slots.clear()
	for side: int in input_sides:
		if side == direction:
			continue  # output side can't also be an input
		if old_slots.has(side):
			input_slots[side] = old_slots[side]
		else:
			input_slots[side] = {"value": NAN, "filled": false}
	_update_symbol_text()
	queue_redraw()

func reset_inputs() -> void:
	for side: int in input_slots:
		input_slots[side].value = NAN
		input_slots[side].filled = false
	queue_redraw()

# --- Ball reception ---

func receive_number(ball_value: float, from_dir: int) -> bool:
	if not input_slots.has(from_dir):
		return false
	if input_slots[from_dir].filled:
		return false
	input_slots[from_dir].value = ball_value
	input_slots[from_dir].filled = true
	queue_redraw()
	_try_compute()
	return true

# --- Computation ---

func _try_compute() -> void:
	if input_slots.size() < 2:
		return
	for side: int in input_slots:
		if not input_slots[side].filled:
			return

	var values: Array[float] = _get_ordered_values()
	var result: float = values[0]
	for i in range(1, values.size()):
		result = _apply_op(result, values[i])

	reset_inputs()

	await get_tree().create_timer(process_delay).timeout
	result_produced.emit(result, grid_pos, direction)

## Returns potential input sides in operand order (A, B, C):
## opposite-of-output first, then clockwise. Excludes output side.
func _get_ordered_input_sides() -> Array[int]:
	var start: int = Constants.opposite_dir(direction)
	var sides: Array[int] = []
	for i in range(4):
		var side: int = (start + i) % 4
		if side != direction:
			sides.append(side)
	return sides

## Order: opposite-of-output first, then clockwise. Keeps subtraction /
## division deterministic relative to the output direction.
func _get_ordered_values() -> Array[float]:
	var start: int = Constants.opposite_dir(direction)
	var values: Array[float] = []
	for i in range(4):
		var side: int = (start + i) % 4
		if input_slots.has(side):
			values.append(input_slots[side].value)
	return values

func _apply_op(a: float, b: float) -> float:
	match op_type:
		Constants.OperatorType.ADD: return a + b
		Constants.OperatorType.SUBTRACT: return a - b
		Constants.OperatorType.MULTIPLY: return a * b
		Constants.OperatorType.DIVIDE: return a / b if b != 0.0 else 0.0
	return 0.0

# --- Drawing ---

func _draw() -> void:
	var half := Constants.CELL_SIZE / 2.0 - MARGIN
	# Background
	draw_rect(Rect2(-half, -half, half * 2, half * 2), Constants.COLOR_OPERATOR, true)
	# Border
	draw_rect(Rect2(-half, -half, half * 2, half * 2), Constants.COLOR_OPERATOR_DARK, false, 2.0)

	# Input indicators
	var is_noncommutative := op_type in [Constants.OperatorType.SUBTRACT, Constants.OperatorType.DIVIDE]
	if is_noncommutative:
		# Dynamic labels: A, B, C only on CONNECTED inputs, in computation order
		var ordered_sides := _get_ordered_input_sides()
		var letters := ["A", "B", "C"]
		var font: Font = ThemeDB.fallback_font
		var letter_idx := 0
		for side: int in ordered_sides:
			if not input_slots.has(side):
				continue
			var dir_vec := Vector2(Constants.DIR_VECTORS[side])
			var center := dir_vec * (half - 12)
			var filled: bool = input_slots[side].filled
			var color: Color = Color(0.9, 0.9, 0.2) if filled else Color(1, 1, 1, 0.7)
			draw_string(font, Vector2(center.x - 6, center.y + 5), letters[letter_idx],
					HORIZONTAL_ALIGNMENT_CENTER, 12, 13, color)
			letter_idx += 1
	else:
		# Commutative ops: simple dot indicators
		for side: int in input_slots:
			var dir_vec := Vector2(Constants.DIR_VECTORS[side])
			var indicator_pos := dir_vec * (half - 6)
			var color := Color(0.9, 0.9, 0.2) if input_slots[side].filled else Color(1, 1, 1, 0.3)
			draw_circle(indicator_pos, 5.0, color)

	# Output arrow
	var angle: float = Constants.DIR_ANGLES[direction]
	var arrow_start := Vector2(cos(angle), sin(angle)) * (half - 8)
	var arrow_end := Vector2(cos(angle), sin(angle)) * (half + 2)
	draw_line(arrow_start, arrow_end, Constants.COLOR_OPERATOR_DARK, 3.0, true)

func _setup_symbol_label() -> void:
	var old_label := get_node_or_null("SymbolLabel")
	if old_label:
		old_label.queue_free()
	var label := Label.new()
	label.name = "SymbolLabel"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_color_override("font_color", Color.WHITE)
	var half := Constants.CELL_SIZE / 2.0 - MARGIN
	label.text = Constants.OP_SYMBOLS[op_type]
	label.add_theme_font_size_override("font_size", 28)
	label.position = Vector2(-half, -16)
	label.size = Vector2(half * 2, 32)
	add_child(label)

## Update the central label text based on connected inputs.
## For non-commutative ops: shows "A−B", "A−B−C" etc.
## For commutative ops: always shows just the symbol.
func _update_symbol_text() -> void:
	var label: Label = get_node_or_null("SymbolLabel")
	if not label:
		return
	var is_noncommutative := op_type in [Constants.OperatorType.SUBTRACT, Constants.OperatorType.DIVIDE]
	if not is_noncommutative:
		return  # commutative ops keep the simple symbol
	var connected_count := input_slots.size()
	var sym: String = Constants.OP_SYMBOLS[op_type]
	if connected_count >= 2:
		var letters := ["A", "B", "C"]
		var parts: PackedStringArray = []
		for i in range(mini(connected_count, 3)):
			parts.append(letters[i])
		label.text = sym.join(parts)
		label.add_theme_font_size_override("font_size", 20 if connected_count == 2 else 16)
	elif connected_count == 1:
		label.text = "A%s?" % sym
		label.add_theme_font_size_override("font_size", 20)
	else:
		label.text = sym
		label.add_theme_font_size_override("font_size", 28)
