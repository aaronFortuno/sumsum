class_name NumberSource
extends Node2D

signal number_emitted(value: float, grid_pos: Vector2i, direction: int)

var grid_pos: Vector2i = Vector2i.ZERO
var direction: int = Constants.Direction.RIGHT
var value: float = 0.0
var is_fixed := true
var emit_timer: float = 0.0
var is_running := false

## Multiple output directions — auto-detected from adjacent conveyors.
## If empty, falls back to the single `direction` field (legacy behavior).
var output_directions: Array[int] = []

## Per-instance tunable (upgradeable in the future)
var emit_interval: float = Constants.SOURCE_EMIT_INTERVAL

const MARGIN := 4.0

func setup(p_pos: Vector2i, p_value: float, p_dir: int) -> void:
	grid_pos = p_pos
	value = p_value
	direction = p_dir
	position = Constants.grid_to_world(grid_pos)
	if has_node("ValueLabel"):
		get_node("ValueLabel").text = Constants.format_number(value)
	queue_redraw()

## Called by GridManager when adjacent conveyors change.
## Updates which directions this source emits to.
func update_output_connections(connected_sides: Array) -> void:
	output_directions.clear()
	for side: int in connected_sides:
		output_directions.append(side)
	queue_redraw()

func get_all_outputs() -> Array[int]:
	if output_directions.is_empty():
		return [direction]
	return output_directions

func start() -> void:
	is_running = true
	emit_timer = 0.0

func stop() -> void:
	is_running = false

func _process(delta: float) -> void:
	if not is_running:
		return
	emit_timer -= delta
	if emit_timer <= 0:
		emit_timer = emit_interval
		# Emit to all connected outputs
		var outputs := get_all_outputs()
		for dir: int in outputs:
			number_emitted.emit(value, grid_pos, dir)

func _draw() -> void:
	var half := Constants.CELL_SIZE / 2.0 - MARGIN
	# Background
	draw_rect(Rect2(-half, -half, half * 2, half * 2), Constants.COLOR_SOURCE, true)
	# Darker border
	draw_rect(Rect2(-half, -half, half * 2, half * 2), Constants.COLOR_SOURCE_DARK, false, 2.0)
	# Output arrows — one per connected direction
	var outputs := get_all_outputs()
	for dir: int in outputs:
		var angle: float = Constants.DIR_ANGLES[dir]
		var arrow_start := Vector2(cos(angle), sin(angle)) * (half - 8)
		var arrow_end := Vector2(cos(angle), sin(angle)) * (half + 2)
		draw_line(arrow_start, arrow_end, Constants.COLOR_SOURCE_DARK, 3.0, true)

func _ready() -> void:
	# Label showing the value
	var label := Label.new()
	label.name = "ValueLabel"
	label.text = Constants.format_number(value)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_color", Color.WHITE)
	var half := Constants.CELL_SIZE / 2.0 - MARGIN
	label.position = Vector2(-half, -14)
	label.size = Vector2(half * 2, 28)
	add_child(label)
