class_name NumberSource
extends Node2D

signal number_emitted(value: float, grid_pos: Vector2i, direction: int)

var grid_pos: Vector2i = Vector2i.ZERO
var direction: int = Constants.Direction.RIGHT
var value: float = 0.0
var is_fixed := true
var emit_timer: float = 0.0
var is_running := false

const MARGIN := 4.0

func setup(p_pos: Vector2i, p_value: float, p_dir: int) -> void:
	grid_pos = p_pos
	value = p_value
	direction = p_dir
	position = Constants.grid_to_world(grid_pos)
	if has_node("ValueLabel"):
		get_node("ValueLabel").text = Constants.format_number(value)
	queue_redraw()

func start() -> void:
	is_running = true
	emit_timer = 0.5  # Small delay before first emit

func stop() -> void:
	is_running = false

func _process(delta: float) -> void:
	if not is_running:
		return
	emit_timer -= delta
	if emit_timer <= 0:
		emit_timer = Constants.SOURCE_EMIT_INTERVAL
		number_emitted.emit(value, grid_pos, direction)

func _draw() -> void:
	var half := Constants.CELL_SIZE / 2.0 - MARGIN
	# Background
	draw_rect(Rect2(-half, -half, half * 2, half * 2), Constants.COLOR_SOURCE, true)
	# Darker border
	draw_rect(Rect2(-half, -half, half * 2, half * 2), Constants.COLOR_SOURCE_DARK, false, 2.0)
	# Output arrow
	var angle: float = Constants.DIR_ANGLES[direction]
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
