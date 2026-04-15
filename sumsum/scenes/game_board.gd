extends Node2D

# --- State ---
var grid_mgr := GridManager.new()
var number_balls: Array[NumberBall] = []
var sources: Array[NumberSource] = []
var operators: Array[OperatorBlock] = []
var targets: Array[TargetBlock] = []

# --- Interaction state ---
var current_tool: int = Constants.ToolMode.CONVEYOR
var current_direction: int = Constants.Direction.RIGHT
var hover_cell: Vector2i = Vector2i(-1, -1)
var level_complete := false

# Conveyor drag (left-click)
var is_dragging := false
var drag_path: Array[Vector2i] = []
var drag_preview_nodes: Array[Conveyor] = []

# Delete drag (right-click)
var is_delete_dragging := false
var delete_selection: Array[Vector2i] = []

# Stopped balls waiting at conveyor exit edges
var occupied_cells: Dictionary = {}  # Vector2i → NumberBall

# --- Camera ---
var camera: Camera2D
var is_panning := false
const ZOOM_MIN := Vector2(0.25, 0.25)
const ZOOM_MAX := Vector2(3.0, 3.0)
const ZOOM_STEP := 1.1
const PAN_SPEED := 400.0  # Pixels per second for keyboard pan

# --- UI layer (screen-fixed) ---
var ui_layer: CanvasLayer

# --- Level state ---
var current_pack: int = 0
var current_level: int = 0
var level_data: Dictionary = {}
var all_packs: Array[Dictionary] = []
var tool_counts: Dictionary = {}  # ToolMode → int (placed count)

# --- Preloaded scenes ---
var ball_scene := preload("res://scenes/components/number_ball.tscn")

func _process(delta: float) -> void:
	# Keyboard pan (WASD + arrows)
	var pan_dir := Vector2.ZERO
	if Input.is_action_pressed("ui_left") or Input.is_action_pressed("pan_left"):
		pan_dir.x -= 1
	if Input.is_action_pressed("ui_right") or Input.is_action_pressed("pan_right"):
		pan_dir.x += 1
	if Input.is_action_pressed("ui_up") or Input.is_action_pressed("pan_up"):
		pan_dir.y -= 1
	if Input.is_action_pressed("ui_down") or Input.is_action_pressed("pan_down"):
		pan_dir.y += 1
	if pan_dir != Vector2.ZERO:
		camera.position += pan_dir.normalized() * PAN_SPEED * delta / camera.zoom.x
		queue_redraw()


func _ready() -> void:
	# Camera for zoom/pan
	camera = Camera2D.new()
	camera.name = "Camera"
	add_child(camera)
	camera.make_current()

	# UI layer: toolbar and labels stay fixed on screen
	ui_layer = CanvasLayer.new()
	ui_layer.name = "UILayer"
	ui_layer.layer = 10
	add_child(ui_layer)

	all_packs = Packs.get_all_packs()
	_show_level_selector()

# --- Coordinate helpers ---

func _screen_to_world(screen_pos: Vector2) -> Vector2:
	return get_canvas_transform().affine_inverse() * screen_pos

func _center_camera_on_level() -> void:
	var grid_size: Vector2i = level_data.get("grid_size", Vector2i(12, 7))
	var center: Vector2 = Constants.GRID_OFFSET + Vector2(grid_size) * Constants.CELL_SIZE / 2.0
	# Offset slightly up to account for toolbar covering the bottom
	center.y -= 30.0
	camera.position = center
	camera.zoom = Vector2.ONE

# ==========================================================================
# Drawing (world space — grid, overlays)
# ==========================================================================

func _draw() -> void:
	# Background (large enough to cover visible area at any zoom)
	var bg_size: float = Constants.GRID_COLS * Constants.CELL_SIZE + 2000
	draw_rect(Rect2(-1000, -1000, bg_size, bg_size), Constants.COLOR_BG, true)

	# Grid background
	var grid_rect := Rect2(
		Constants.GRID_OFFSET,
		Vector2(Constants.GRID_COLS * Constants.CELL_SIZE, Constants.GRID_ROWS * Constants.CELL_SIZE)
	)
	draw_rect(grid_rect, Constants.COLOR_GRID_BG, true)

	# Grid lines
	for x in range(Constants.GRID_COLS + 1):
		var from := Constants.GRID_OFFSET + Vector2(x * Constants.CELL_SIZE, 0)
		var to := from + Vector2(0, Constants.GRID_ROWS * Constants.CELL_SIZE)
		draw_line(from, to, Constants.COLOR_GRID_LINE, 1.0)
	for y in range(Constants.GRID_ROWS + 1):
		var from := Constants.GRID_OFFSET + Vector2(0, y * Constants.CELL_SIZE)
		var to := from + Vector2(Constants.GRID_COLS * Constants.CELL_SIZE, 0)
		draw_line(from, to, Constants.COLOR_GRID_LINE, 1.0)

	# Delete selection overlay
	if is_delete_dragging:
		for cell in delete_selection:
			var world_pos := Constants.grid_to_world(cell)
			var half := Constants.CELL_SIZE / 2.0
			draw_rect(
				Rect2(world_pos.x - half, world_pos.y - half, Constants.CELL_SIZE, Constants.CELL_SIZE),
				Color(1, 0.15, 0.15, 0.3), true
			)

	# Hover preview (when not dragging)
	if not is_dragging and not is_delete_dragging:
		if current_tool != Constants.ToolMode.NONE and Constants.is_valid_cell(hover_cell):
			var world_pos := Constants.grid_to_world(hover_cell)
			var half := Constants.CELL_SIZE / 2.0
			var can_place := not grid_mgr.has_cell(hover_cell)
			var hover_color: Color = Constants.COLOR_HOVER if can_place else Constants.COLOR_INVALID
			draw_rect(
				Rect2(world_pos.x - half, world_pos.y - half, Constants.CELL_SIZE, Constants.CELL_SIZE),
				hover_color, true
			)

# ==========================================================================
# Toolbar drawing (screen-space via CanvasLayer sub-node)
# ==========================================================================

var _toolbar_draw_node: Node2D

func _ensure_toolbar_draw_node() -> void:
	if _toolbar_draw_node != null and is_instance_valid(_toolbar_draw_node):
		return
	_toolbar_draw_node = Node2D.new()
	_toolbar_draw_node.name = "ToolbarDraw"
	_toolbar_draw_node.draw.connect(_on_toolbar_draw)
	ui_layer.add_child(_toolbar_draw_node)

## Fixed tool order — always shown in toolbar
const TOOLBAR_TOOLS: Array[int] = [
	Constants.ToolMode.CONVEYOR,
	Constants.ToolMode.OPERATOR_ADD,
	Constants.ToolMode.OPERATOR_SUB,
	Constants.ToolMode.OPERATOR_MUL,
	Constants.ToolMode.OPERATOR_DIV,
	Constants.ToolMode.SPLITTER,
]

const TOOL_SYMBOLS := {
	Constants.ToolMode.CONVEYOR: "⇢",
	Constants.ToolMode.OPERATOR_ADD: "+",
	Constants.ToolMode.OPERATOR_SUB: "−",
	Constants.ToolMode.OPERATOR_MUL: "×",
	Constants.ToolMode.OPERATOR_DIV: "÷",
	Constants.ToolMode.SPLITTER: "⇅",
}

const TOOL_TOOLTIPS := {
	Constants.ToolMode.CONVEYOR: "Cinta transportadora",
	Constants.ToolMode.OPERATOR_ADD: "Sumador",
	Constants.ToolMode.OPERATOR_SUB: "Restador",
	Constants.ToolMode.OPERATOR_MUL: "Multiplicador",
	Constants.ToolMode.OPERATOR_DIV: "Divisor",
	Constants.ToolMode.SPLITTER: "Canvi d'agulles",
}

## Returns which tools the player has seen in any level up to (and including)
## the current one. Used to show "known but unavailable" vs "unknown".
func _get_known_tools() -> Dictionary:
	var known := {}
	for p_idx in range(all_packs.size()):
		var pack: Dictionary = all_packs[p_idx]
		var pack_levels: Array = pack.get("levels", [])
		for l_idx in range(pack_levels.size()):
			if p_idx > current_pack or (p_idx == current_pack and l_idx > current_level):
				break
			for tool_id in pack_levels[l_idx].get("available_tools", []):
				known[tool_id] = true
		if p_idx > current_pack:
			break
	return known

func _on_toolbar_draw() -> void:
	var td := _toolbar_draw_node

	# Top info bar background
	td.draw_rect(Rect2(0, 0, 1280, 55), Color(0.08, 0.08, 0.1, 0.85), true)
	td.draw_line(Vector2(0, 55), Vector2(1280, 55), Constants.COLOR_GRID_LINE, 1.0)

	# Toolbar background
	td.draw_rect(Rect2(0, 620, 1280, 100), Constants.COLOR_TOOLBAR_BG, true)
	td.draw_line(Vector2(0, 620), Vector2(1280, 620), Constants.COLOR_GRID_LINE, 2.0)

	# Tool buttons — always show all 5, with states
	var available: Array = level_data.get("available_tools", [])
	var known: Dictionary = _get_known_tools()
	var btn_size := 70.0
	var spacing := 10.0
	var start_x := 200.0

	for i in range(TOOLBAR_TOOLS.size()):
		var tool_id: int = TOOLBAR_TOOLS[i]
		var x: float = start_x + i * (btn_size + spacing)
		var rect := Rect2(x, 632, btn_size, btn_size)

		var is_available: bool = tool_id in available
		var is_known: bool = known.has(tool_id)

		var btn_color: Color
		if not is_known:
			# Unknown: very dark, locked
			btn_color = Color(0.12, 0.12, 0.15)
		elif not is_available:
			# Known but not in this level: dimmed
			btn_color = Color(0.18, 0.18, 0.22)
		elif tool_id == current_tool:
			# Selected
			btn_color = Constants.COLOR_TOOLBAR_BTN_SEL
		else:
			# Available
			btn_color = Constants.COLOR_TOOLBAR_BTN

		td.draw_rect(rect, btn_color, true)
		var border_color: Color = btn_color.lightened(0.15) if is_known else btn_color.lightened(0.05)
		td.draw_rect(rect, border_color, false, 1.5)

		# Shortcut number (small, top-right corner)
		if is_known:
			var font: Font = ThemeDB.fallback_font
			var num_color := Color(1, 1, 1, 0.3) if is_available else Color(1, 1, 1, 0.12)
			td.draw_string(font, Vector2(x + btn_size - 14, 646), str(i + 1),
				HORIZONTAL_ALIGNMENT_LEFT, -1, 10, num_color)

func _redraw_toolbar() -> void:
	if _toolbar_draw_node != null and is_instance_valid(_toolbar_draw_node):
		_toolbar_draw_node.queue_redraw()
	# Update limit counters
	var limits: Dictionary = level_data.get("tool_limits", {})
	for tool_id: int in limits:
		var count_label: Label = ui_layer.get_node_or_null("LimitLabel_%d" % tool_id)
		if count_label:
			var used: int = tool_counts.get(tool_id, 0)
			var max_count: int = limits[tool_id]
			count_label.text = "%d/%d" % [used, max_count]
			count_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.6) if used < max_count else Color(1, 0.3, 0.3, 0.8))

# ==========================================================================
# Level management
# ==========================================================================

func load_pack_level(pack_idx: int, level_idx: int) -> void:
	current_pack = pack_idx
	current_level = level_idx
	if pack_idx >= all_packs.size():
		return
	var pack: Dictionary = all_packs[pack_idx]
	var pack_levels: Array = pack.get("levels", [])
	if level_idx >= pack_levels.size():
		return
	level_data = pack_levels[level_idx]
	_clear_board()
	_setup_level()
	_setup_toolbar()
	_setup_level_info()
	current_tool = Constants.ToolMode.CONVEYOR
	_center_camera_on_level()
	# Simulation always running: start sources immediately
	for source in sources:
		source.start()
	queue_redraw()
	_redraw_toolbar()

func _clear_board() -> void:
	level_complete = false
	for source in sources:
		source.stop()
	_clear_drag_preview()
	grid_mgr.clear_all()
	for ball in number_balls:
		if is_instance_valid(ball):
			ball.queue_free()
	number_balls.clear()
	occupied_cells.clear()
	sources.clear()
	operators.clear()
	targets.clear()
	tool_counts.clear()

	# Clear UI labels from ui_layer
	for child in ui_layer.get_children():
		if child.is_in_group("toolbar_ui") or child.is_in_group("level_ui"):
			child.queue_free()
	# Also clear any that were left on game_board directly
	for child in get_children():
		if child.is_in_group("toolbar_ui") or child.is_in_group("level_ui"):
			child.queue_free()

func _setup_level() -> void:
	for s_data in level_data.get("sources", []):
		var source := NumberSource.new()
		add_child(source)
		source.setup(s_data["pos"], s_data["value"], s_data["dir"])
		source.number_emitted.connect(_on_source_emit)
		sources.append(source)
		grid_mgr.set_cell(s_data["pos"], Constants.ComponentType.SOURCE, source)

	for t_data in level_data.get("targets", []):
		var target := TargetBlock.new()
		add_child(target)
		target.setup(t_data["pos"], t_data["value"])
		target.target_reached.connect(_on_target_reached)
		targets.append(target)
		grid_mgr.set_cell(t_data["pos"], Constants.ComponentType.TARGET, target)

	for o_data in level_data.get("fixed_operators", []):
		_place_operator(o_data["pos"], o_data["op"], o_data["dir"], true)

	for c_data in level_data.get("fixed_conveyors", []):
		_place_conveyor(c_data["pos"], c_data["dir"])
		var cell_data: Dictionary = grid_mgr.get_cell(c_data["pos"])
		if not cell_data.is_empty():
			cell_data["node"].is_fixed = true

func _setup_toolbar() -> void:
	_ensure_toolbar_draw_node()

	var available: Array = level_data.get("available_tools", [])
	var known: Dictionary = _get_known_tools()
	var btn_size := 70.0
	var spacing := 10.0
	var start_x: float = 200.0

	for i in range(TOOLBAR_TOOLS.size()):
		var tool_id: int = TOOLBAR_TOOLS[i]
		var x: float = start_x + i * (btn_size + spacing)
		var is_available: bool = tool_id in available
		var is_known: bool = known.has(tool_id)

		var label := Label.new()
		if not is_known:
			label.text = "?"
		else:
			label.text = TOOL_SYMBOLS.get(tool_id, "?")
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 22)
		if not is_known:
			label.add_theme_color_override("font_color", Color(1, 1, 1, 0.1))
		elif not is_available:
			label.add_theme_color_override("font_color", Color(1, 1, 1, 0.25))
		else:
			label.add_theme_color_override("font_color", Color.WHITE)
		label.tooltip_text = TOOL_TOOLTIPS.get(tool_id, "") + " [%d]" % (i + 1) if is_known else ""
		label.position = Vector2(x, 632)
		label.size = Vector2(btn_size, btn_size)
		label.mouse_filter = Control.MOUSE_FILTER_PASS
		label.add_to_group("toolbar_ui")
		label.z_index = 5
		ui_layer.add_child(label)

		# Show limit counter under button if tool_limits applies
		var limits: Dictionary = level_data.get("tool_limits", {})
		if is_available and limits.has(tool_id):
			var count_label := Label.new()
			count_label.name = "LimitLabel_%d" % tool_id
			var used: int = tool_counts.get(tool_id, 0)
			var max_count: int = limits[tool_id]
			count_label.text = "%d/%d" % [used, max_count]
			count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			count_label.add_theme_font_size_override("font_size", 11)
			count_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.6) if used < max_count else Color(1, 0.3, 0.3, 0.8))
			count_label.position = Vector2(x, 700)
			count_label.size = Vector2(btn_size, 16)
			count_label.add_to_group("toolbar_ui")
			count_label.z_index = 5
			ui_layer.add_child(count_label)

	var hint_label := Label.new()
	hint_label.name = "HintLabel"
	hint_label.text = "[1-5] Eines  |  [R] Girar  |  Dret: Esborrar  |  WASD: Moure"
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hint_label.add_theme_font_size_override("font_size", 10)
	hint_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.35))
	hint_label.position = Vector2(10, 675)
	hint_label.size = Vector2(350, 25)
	hint_label.add_to_group("toolbar_ui")
	hint_label.z_index = 5
	ui_layer.add_child(hint_label)

	# HUD buttons (right side of toolbar)
	var menu_btn := Button.new()
	menu_btn.text = "Menú"
	menu_btn.position = Vector2(1080, 640)
	menu_btn.size = Vector2(80, 30)
	menu_btn.add_to_group("toolbar_ui")
	menu_btn.pressed.connect(_show_level_selector)
	ui_layer.add_child(menu_btn)

	var reset_btn := Button.new()
	reset_btn.text = "Reiniciar"
	reset_btn.position = Vector2(1080, 676)
	reset_btn.size = Vector2(80, 30)
	reset_btn.add_to_group("toolbar_ui")
	reset_btn.pressed.connect(_reset_current_level)
	ui_layer.add_child(reset_btn)

func _setup_level_info() -> void:
	# Pack + level title (left)
	var title_label := Label.new()
	title_label.name = "LevelTitle"
	var pack_title: String = all_packs[current_pack].get("title", "")
	title_label.text = "%s — Nivell %d: %s" % [pack_title, current_level + 1, level_data.get("title", "")]
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	title_label.add_theme_font_size_override("font_size", 14)
	title_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.6))
	title_label.position = Vector2(20, 4)
	title_label.size = Vector2(400, 22)
	title_label.add_to_group("level_ui")
	ui_layer.add_child(title_label)

	# Objective / description (centered, prominent)
	var desc: String = level_data.get("description", "")
	if desc != "":
		var desc_label := Label.new()
		desc_label.name = "LevelDesc"
		desc_label.text = desc
		desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		desc_label.add_theme_font_size_override("font_size", 22)
		desc_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.95))
		desc_label.position = Vector2(200, 12)
		desc_label.size = Vector2(880, 35)
		desc_label.add_to_group("level_ui")
		ui_layer.add_child(desc_label)

# ==========================================================================
# Input handling
# ==========================================================================

func _input(event: InputEvent) -> void:
	# Block game input when level is complete or selector is open
	if level_complete or _selector_visible:
		# Still allow zoom/pan for looking around
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
				_zoom_at(event.position, ZOOM_STEP)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
				_zoom_at(event.position, 1.0 / ZOOM_STEP)
		return

	if event is InputEventMouseMotion:
		if is_panning:
			camera.position -= event.relative / camera.zoom
			queue_redraw()
			return
		var world_pos := _screen_to_world(event.position)
		hover_cell = Constants.world_to_grid(world_pos)
		if is_dragging:
			_extend_drag_path(hover_cell)
		if is_delete_dragging:
			_extend_delete_selection(hover_cell)
		queue_redraw()

	if event is InputEventMouseButton:
		# Zoom
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_zoom_at(event.position, ZOOM_STEP)
			return
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_zoom_at(event.position, 1.0 / ZOOM_STEP)
			return
		# Pan
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			is_panning = event.pressed
			return
		# Left click
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# Toolbar is in screen space
				if event.position.y > 620:
					_handle_toolbar_click(event.position)
				else:
					_handle_left_press(_screen_to_world(event.position))
			else:
				_handle_left_release()
		# Right click
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				_handle_right_press(_screen_to_world(event.position))
			else:
				_handle_right_release()

	# Tool shortcuts (1-5)
	if event is InputEventKey and event.pressed and not event.echo:
		var key: int = event.keycode
		if key >= KEY_1 and key <= KEY_5:
			var idx: int = key - KEY_1
			if idx < TOOLBAR_TOOLS.size():
				_try_select_tool(idx)

	if event.is_action_pressed("rotate"):
		_handle_rotate()

	if event.is_action_pressed("ui_cancel"):
		if is_dragging:
			_cancel_drag()
		if is_delete_dragging:
			_cancel_delete_drag()

func _zoom_at(screen_pos: Vector2, factor: float) -> void:
	var old_world := _screen_to_world(screen_pos)
	camera.zoom = (camera.zoom * factor).clamp(ZOOM_MIN, ZOOM_MAX)
	var new_world := _screen_to_world(screen_pos)
	camera.position += old_world - new_world
	queue_redraw()

func _handle_left_press(world_pos: Vector2) -> void:
	var cell := Constants.world_to_grid(world_pos)
	if not Constants.is_valid_cell(cell):
		return

	if current_tool == Constants.ToolMode.CONVEYOR:
		is_dragging = true
		drag_path = [cell]
		_rebuild_drag_preview()
		queue_redraw()
	elif current_tool in [Constants.ToolMode.OPERATOR_ADD, Constants.ToolMode.OPERATOR_SUB,
			Constants.ToolMode.OPERATOR_MUL, Constants.ToolMode.OPERATOR_DIV]:
		var op_type: int = _tool_to_op_type(current_tool)
		_place_operator(cell, op_type, current_direction, false)
	elif current_tool == Constants.ToolMode.SPLITTER:
		_place_splitter(cell)

func _handle_left_release() -> void:
	if is_dragging:
		if current_tool == Constants.ToolMode.CONVEYOR:
			_finish_conveyor_drag()
		is_dragging = false
		drag_path.clear()
		_clear_drag_preview()
		queue_redraw()

func _handle_right_press(world_pos: Vector2) -> void:
	var cell := Constants.world_to_grid(world_pos)
	if not Constants.is_valid_cell(cell):
		return
	if is_dragging:
		_cancel_drag()
		return

	if grid_mgr.has_cell(cell):
		var node: Node2D = grid_mgr.get_node_at(cell)
		if not node.get("is_fixed"):
			is_delete_dragging = true
			delete_selection = [cell]
			queue_redraw()

func _handle_right_release() -> void:
	if is_delete_dragging:
		for cell in delete_selection:
			_delete_at(cell)
		is_delete_dragging = false
		delete_selection.clear()
		queue_redraw()

func _handle_rotate() -> void:
	if Constants.is_valid_cell(hover_cell) and grid_mgr.has_cell(hover_cell):
		var node: Node2D = grid_mgr.get_node_at(hover_cell)
		if node.has_method("rotate_cw") and not node.get("is_fixed"):
			node.rotate_cw()
			grid_mgr.update_neighbor_inputs(hover_cell)
			AudioManager.play_sfx("rotate")
			return
	current_direction = Constants.next_direction(current_direction)
	queue_redraw()

func _try_select_tool(idx: int) -> void:
	var available: Array = level_data.get("available_tools", [])
	var tool_id: int = TOOLBAR_TOOLS[idx]
	if tool_id in available and not _is_tool_exhausted(tool_id):
		current_tool = tool_id
		queue_redraw()
		_redraw_toolbar()

func _handle_toolbar_click(pos: Vector2) -> void:
	var available: Array = level_data.get("available_tools", [])
	var btn_size := 70.0
	var spacing := 10.0
	var start_x := 200.0

	for i in range(TOOLBAR_TOOLS.size()):
		var x: float = start_x + i * (btn_size + spacing)
		if pos.x >= x and pos.x <= x + btn_size and pos.y >= 632 and pos.y <= 702:
			var tool_id: int = TOOLBAR_TOOLS[i]
			if tool_id in available and not _is_tool_exhausted(tool_id):
				current_tool = tool_id
				queue_redraw()
				_redraw_toolbar()
			return

# ==========================================================================
# Conveyor drag (left-click)
# ==========================================================================

func _extend_drag_path(cell: Vector2i) -> void:
	if not Constants.is_valid_cell(cell):
		return
	if drag_path.is_empty():
		return

	var last_cell := drag_path[-1]
	if cell == last_cell:
		return

	var changed := false

	var idx := drag_path.find(cell)
	if idx != -1:
		drag_path.resize(idx + 1)
		changed = true
	else:
		var delta := cell - last_cell
		if abs(delta.x) + abs(delta.y) == 1:
			drag_path.append(cell)
			changed = true
		else:
			_trace_line_to(cell)
			changed = true

	if changed:
		_rebuild_drag_preview()

func _trace_line_to(target: Vector2i) -> void:
	var current := drag_path[-1]
	var safety := 50
	while current != target and safety > 0:
		safety -= 1
		var delta := target - current
		var step: Vector2i
		if abs(delta.x) >= abs(delta.y):
			step = Vector2i(signi(delta.x), 0)
		else:
			step = Vector2i(0, signi(delta.y))
		current = current + step
		if not Constants.is_valid_cell(current):
			break
		if current in drag_path:
			continue
		drag_path.append(current)

func _finish_conveyor_drag() -> void:
	if drag_path.size() == 1:
		_place_conveyor(drag_path[0], current_direction)
		return

	for i in range(drag_path.size()):
		var cell: Vector2i = drag_path[i]
		var dir: int
		if i < drag_path.size() - 1:
			dir = _direction_between(drag_path[i], drag_path[i + 1])
		else:
			dir = _direction_between(drag_path[i - 1], drag_path[i])
		_place_conveyor(cell, dir)

func _cancel_drag() -> void:
	is_dragging = false
	drag_path.clear()
	_clear_drag_preview()
	queue_redraw()

func _are_perpendicular(dir_a: int, dir_b: int) -> bool:
	return abs(dir_a - dir_b) % 2 == 1

func _direction_between(from: Vector2i, to: Vector2i) -> int:
	var delta := to - from
	if delta.x > 0: return Constants.Direction.RIGHT
	if delta.x < 0: return Constants.Direction.LEFT
	if delta.y > 0: return Constants.Direction.DOWN
	return Constants.Direction.UP

# --- Drag preview ---

func _rebuild_drag_preview() -> void:
	_clear_drag_preview()

	for i in range(drag_path.size()):
		var cell: Vector2i = drag_path[i]
		if grid_mgr.has_cell(cell) and grid_mgr.get_cell_type(cell) != Constants.ComponentType.CONVEYOR:
			continue

		var dir: int
		if drag_path.size() == 1:
			dir = current_direction
		elif i < drag_path.size() - 1:
			dir = _direction_between(drag_path[i], drag_path[i + 1])
		else:
			dir = _direction_between(drag_path[i - 1], drag_path[i])

		var conv := Conveyor.new()
		add_child(conv)
		conv.setup(cell, dir)
		conv.modulate.a = 0.5
		conv.z_index = 5

		if i > 0:
			var input_side: int = _direction_between(drag_path[i], drag_path[i - 1])
			conv.set_input_direction(input_side)

		drag_preview_nodes.append(conv)

func _clear_drag_preview() -> void:
	for node in drag_preview_nodes:
		if is_instance_valid(node):
			node.queue_free()
	drag_preview_nodes.clear()

# ==========================================================================
# Delete drag (right-click)
# ==========================================================================

func _extend_delete_selection(cell: Vector2i) -> void:
	if not Constants.is_valid_cell(cell):
		return
	if cell in delete_selection:
		return
	if not grid_mgr.has_cell(cell):
		return
	var node: Node2D = grid_mgr.get_node_at(cell)
	if node.get("is_fixed"):
		return
	delete_selection.append(cell)
	queue_redraw()

func _cancel_delete_drag() -> void:
	is_delete_dragging = false
	delete_selection.clear()
	queue_redraw()

# ==========================================================================
# Placement
# ==========================================================================

func _place_conveyor(cell: Vector2i, dir: int) -> void:
	if grid_mgr.has_cell(cell):
		var data: Dictionary = grid_mgr.get_cell(cell)
		if data["type"] == Constants.ComponentType.CONVEYOR:
			var conv: Conveyor = data["node"]
			if not conv.is_crossing and _are_perpendicular(conv.direction, dir):
				conv.is_crossing = true
			elif not conv.is_crossing:
				conv.direction = dir
			conv.queue_redraw()
			grid_mgr.update_neighbor_inputs(cell)
			_try_resume_behind(cell)
		return

	var conv := Conveyor.new()
	add_child(conv)
	conv.setup(cell, dir)
	grid_mgr.set_cell(cell, Constants.ComponentType.CONVEYOR, conv)
	grid_mgr.update_neighbor_inputs(cell)
	_try_resume_behind(cell)
	_trigger_adjacent_sources(cell)
	AudioManager.play_sfx("place")

## If a source neighbor points to [cell], trigger an immediate emission.
func _trigger_adjacent_sources(cell: Vector2i) -> void:
	for dir in range(4):
		var neighbor: Vector2i = cell + Constants.DIR_VECTORS[dir]
		if not grid_mgr.has_cell(neighbor):
			continue
		var n_data: Dictionary = grid_mgr.get_cell(neighbor)
		if n_data["type"] == Constants.ComponentType.SOURCE:
			var source: NumberSource = n_data["node"]
			if not source.is_running:
				continue
			var target: Vector2i = neighbor + Constants.DIR_VECTORS[source.direction]
			if target == cell:
				# Source points to our new cell — emit now
				source.emit_timer = 0.0

func _place_operator(cell: Vector2i, op_type: int, dir: int, fixed: bool) -> void:
	if grid_mgr.has_cell(cell):
		return

	# Check tool limit for non-fixed operators
	if not fixed:
		var tool_mode: int = _op_type_to_tool(op_type)
		var limits: Dictionary = level_data.get("tool_limits", {})
		if limits.has(tool_mode):
			var current: int = tool_counts.get(tool_mode, 0)
			if current >= limits[tool_mode]:
				return
		tool_counts[tool_mode] = tool_counts.get(tool_mode, 0) + 1
		_redraw_toolbar()

	var op := OperatorBlock.new()
	add_child(op)
	op.setup(cell, op_type, dir, fixed)
	op.result_produced.connect(_on_operator_result)
	operators.append(op)
	grid_mgr.set_cell(cell, Constants.ComponentType.OPERATOR, op)
	grid_mgr.update_cell_connections(cell)
	AudioManager.play_sfx("place")

	# Auto-switch to conveyor if current tool is now exhausted
	if not fixed and _is_tool_exhausted(current_tool):
		current_tool = Constants.ToolMode.CONVEYOR
		_redraw_toolbar()

func _place_splitter(cell: Vector2i) -> void:
	if grid_mgr.has_cell(cell):
		return
	var spl := SplitterBlock.new()
	add_child(spl)
	spl.setup(cell)
	grid_mgr.set_cell(cell, Constants.ComponentType.SPLITTER, spl)
	grid_mgr.update_cell_connections(cell)
	AudioManager.play_sfx("place")

func _delete_at(cell: Vector2i) -> void:
	if not grid_mgr.has_cell(cell):
		return
	var data: Dictionary = grid_mgr.get_cell(cell)
	var node: Node2D = data["node"]
	if node.get("is_fixed"):
		return

	# Destroy any ball stopped at this cell
	if occupied_cells.has(cell):
		_destroy_ball(occupied_cells[cell])

	if data["type"] == Constants.ComponentType.OPERATOR:
		var op: OperatorBlock = node
		var tool_mode: int = _op_type_to_tool(op.op_type)
		tool_counts[tool_mode] = maxi(tool_counts.get(tool_mode, 0) - 1, 0)
		operators.erase(node)
		_redraw_toolbar()
	node.queue_free()
	grid_mgr.erase_cell(cell)
	grid_mgr.recalc_neighbors(cell)
	AudioManager.play_sfx("delete")

func _tool_to_op_type(tool: int) -> int:
	match tool:
		Constants.ToolMode.OPERATOR_ADD: return Constants.OperatorType.ADD
		Constants.ToolMode.OPERATOR_SUB: return Constants.OperatorType.SUBTRACT
		Constants.ToolMode.OPERATOR_MUL: return Constants.OperatorType.MULTIPLY
		Constants.ToolMode.OPERATOR_DIV: return Constants.OperatorType.DIVIDE
	return Constants.OperatorType.ADD

func _op_type_to_tool(op: int) -> int:
	match op:
		Constants.OperatorType.ADD: return Constants.ToolMode.OPERATOR_ADD
		Constants.OperatorType.SUBTRACT: return Constants.ToolMode.OPERATOR_SUB
		Constants.OperatorType.MULTIPLY: return Constants.ToolMode.OPERATOR_MUL
		Constants.OperatorType.DIVIDE: return Constants.ToolMode.OPERATOR_DIV
	return Constants.ToolMode.NONE

func _is_tool_exhausted(tool_id: int) -> bool:
	var limits: Dictionary = level_data.get("tool_limits", {})
	if not limits.has(tool_id):
		return false
	return tool_counts.get(tool_id, 0) >= limits[tool_id]

# ==========================================================================
# Ball routing
# ==========================================================================

func _on_source_emit(value: float, source_pos: Vector2i, dir: int) -> void:
	var next_pos: Vector2i = source_pos + Constants.DIR_VECTORS[dir]
	if _is_cell_blocked(next_pos, source_pos):
		return
	_spawn_ball(value, source_pos, next_pos)

func _on_operator_result(value: float, op_pos: Vector2i, dir: int) -> void:
	var next_pos: Vector2i = op_pos + Constants.DIR_VECTORS[dir]
	_spawn_ball(value, op_pos, next_pos)
	# Operator slots are now free — resume waiting balls
	_try_resume_behind(op_pos)

func _spawn_ball(value: float, from_pos: Vector2i, to_pos: Vector2i) -> void:
	var ball: NumberBall = ball_scene.instantiate()
	add_child(ball)
	ball.setup(value, from_pos)
	ball.arrived.connect(_on_ball_arrived)
	number_balls.append(ball)

	if _is_cell_blocked(to_pos, from_pos):
		_destroy_ball(ball)
		return

	_route_ball(ball, to_pos)

func _on_ball_arrived(ball: NumberBall, grid_pos: Vector2i) -> void:
	if not is_instance_valid(ball):
		return

	if not grid_mgr.has_cell(grid_pos):
		_destroy_ball(ball)
		return

	var data: Dictionary = grid_mgr.get_cell(grid_pos)
	match data["type"]:
		Constants.ComponentType.CONVEYOR:
			var conv: Conveyor = data["node"]
			var output_dir: int = conv.get_output_for(ball.from_direction)
			var next_pos: Vector2i = grid_pos + Constants.DIR_VECTORS[output_dir]
			if _is_cell_blocked(next_pos, grid_pos):
				_stop_ball(ball)
				return
			_route_ball(ball, next_pos)

		Constants.ComponentType.OPERATOR:
			var op: OperatorBlock = data["node"]
			op.receive_number(ball.value, ball.from_direction)
			_destroy_ball(ball)

		Constants.ComponentType.TARGET:
			var target: TargetBlock = data["node"]
			target.receive_number(ball.value)
			_destroy_ball(ball)
			_check_win()

		Constants.ComponentType.SOURCE:
			_destroy_ball(ball)

		Constants.ComponentType.SPLITTER:
			var spl: SplitterBlock = data["node"]
			var out_dir: int = spl.peek_next_output()
			if out_dir < 0:
				_stop_ball(ball)
				return
			var next_pos: Vector2i = grid_pos + Constants.DIR_VECTORS[out_dir]
			if _is_cell_blocked(next_pos, grid_pos):
				_stop_ball(ball)
				return
			spl.advance_output()
			_route_ball(ball, next_pos)

func _route_ball(ball: NumberBall, cell_pos: Vector2i) -> void:
	if not grid_mgr.has_cell(cell_pos):
		_stop_ball(ball)
		return

	var data: Dictionary = grid_mgr.get_cell(cell_pos)
	var half: float = float(Constants.CELL_SIZE) / 2.0

	match data["type"]:
		Constants.ComponentType.CONVEYOR:
			var conv: Conveyor = data["node"]
			var entry_side: int = _direction_between(cell_pos, ball.grid_pos)
			var output_dir: int = conv.get_output_for(entry_side)
			if conv.is_corner_for(entry_side):
				var curve: Dictionary = conv.get_curve_info_for(entry_side)
				var cell_world: Vector2 = Constants.grid_to_world(cell_pos)
				var pivot_local: Vector2 = curve.pivot
				var ea: float = curve.end_angle
				var r: float = curve.radius
				var exit_pt: Vector2 = cell_world + pivot_local + Vector2(cos(ea), sin(ea)) * r
				ball.move_to_exit(cell_pos, exit_pt, curve)
			else:
				var dir_vec: Vector2 = Vector2(Constants.DIR_VECTORS[output_dir])
				var exit_pt: Vector2 = Constants.grid_to_world(cell_pos) + dir_vec * half
				ball.move_to_exit(cell_pos, exit_pt)

		Constants.ComponentType.OPERATOR, Constants.ComponentType.TARGET, \
		Constants.ComponentType.SPLITTER:
			ball.move_to(cell_pos)

		Constants.ComponentType.SOURCE:
			_destroy_ball(ball)

# --- Queue system ---

func _is_cell_blocked(cell_pos: Vector2i, from_cell: Vector2i = Vector2i(-999, -999)) -> bool:
	if not Constants.is_valid_cell(cell_pos):
		return true
	if not grid_mgr.has_cell(cell_pos):
		return true
	if occupied_cells.has(cell_pos):
		return true
	# Check operator capacity
	if from_cell != Vector2i(-999, -999) and grid_mgr.has_cell(cell_pos):
		var data: Dictionary = grid_mgr.get_cell(cell_pos)
		if data["type"] == Constants.ComponentType.OPERATOR:
			var op: OperatorBlock = data["node"]
			var entry_side: int = _direction_between(cell_pos, from_cell)
			if not op.can_receive(entry_side):
				return true
	return false

func _stop_ball(ball: NumberBall) -> void:
	occupied_cells[ball.grid_pos] = ball

func _resume_ball(ball: NumberBall) -> void:
	var old_cell: Vector2i = ball.grid_pos
	occupied_cells.erase(old_cell)
	_on_ball_arrived(ball, old_cell)
	_try_resume_behind(old_cell)

func _try_resume_behind(freed_cell: Vector2i) -> void:
	for dir in range(4):
		var neighbor: Vector2i = freed_cell + Constants.DIR_VECTORS[dir]
		if not occupied_cells.has(neighbor):
			continue
		var waiting_ball: NumberBall = occupied_cells[neighbor]
		if not is_instance_valid(waiting_ball):
			occupied_cells.erase(neighbor)
			continue
		var conv := grid_mgr.get_conveyor(neighbor)
		if conv == null:
			continue
		var output_dir: int = conv.get_output_for(waiting_ball.from_direction)
		var next_pos: Vector2i = neighbor + Constants.DIR_VECTORS[output_dir]
		if next_pos == freed_cell:
			_delayed_resume(waiting_ball)
			return

func _delayed_resume(ball: NumberBall) -> void:
	await get_tree().create_timer(0.12).timeout
	if is_instance_valid(ball) and occupied_cells.has(ball.grid_pos):
		_resume_ball(ball)

func _on_target_reached(_target: TargetBlock, _value: float, _is_correct: bool) -> void:
	queue_redraw()

func _destroy_ball(ball: NumberBall) -> void:
	if is_instance_valid(ball):
		occupied_cells.erase(ball.grid_pos)
		number_balls.erase(ball)
		ball.queue_free()

# ==========================================================================
# Win condition
# ==========================================================================

func _check_win() -> void:
	if level_complete:
		return
	for t in targets:
		if not t.is_satisfied:
			return
	level_complete = true
	SaveManager.mark_level_complete(current_pack, current_level)
	AudioManager.play_sfx("win")
	_on_level_complete()

func _on_level_complete() -> void:
	for source in sources:
		source.stop()
	for ball in number_balls:
		if is_instance_valid(ball):
			ball.queue_free()
	number_balls.clear()
	occupied_cells.clear()
	for op in operators:
		op.reset_inputs()

	# Dark panel behind win message
	var panel := ColorRect.new()
	panel.color = Color(0.05, 0.08, 0.05, 0.85)
	panel.position = Vector2(290, 260)
	panel.size = Vector2(700, 160)
	panel.add_to_group("level_ui")
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	ui_layer.add_child(panel)

	var win_label := Label.new()
	win_label.text = "Nivell completat!"
	win_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	win_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	win_label.add_theme_font_size_override("font_size", 36)
	win_label.add_theme_color_override("font_color", Constants.COLOR_TARGET_OK)
	win_label.position = Vector2(340, 275)
	win_label.size = Vector2(600, 60)
	win_label.add_to_group("level_ui")
	ui_layer.add_child(win_label)

	await get_tree().create_timer(1.5).timeout
	var pack_levels: Array = all_packs[current_pack].get("levels", [])
	var has_next_level: bool = current_level + 1 < pack_levels.size()
	var has_next_pack: bool = current_pack + 1 < all_packs.size()

	if has_next_level or has_next_pack:
		var next_btn := Button.new()
		if has_next_level:
			next_btn.text = "Següent nivell"
		else:
			var next_pack_title: String = all_packs[current_pack + 1].get("title", "")
			next_btn.text = "Següent pack: %s" % next_pack_title
		next_btn.position = Vector2(515, 345)
		next_btn.size = Vector2(250, 40)
		next_btn.add_to_group("level_ui")
		next_btn.pressed.connect(func():
			if has_next_level:
				load_pack_level(current_pack, current_level + 1)
			else:
				load_pack_level(current_pack + 1, 0)
		)
		ui_layer.add_child(next_btn)

		var menu_btn := Button.new()
		menu_btn.text = "Menú"
		menu_btn.position = Vector2(515, 390)
		menu_btn.size = Vector2(250, 35)
		menu_btn.add_to_group("level_ui")
		menu_btn.pressed.connect(_show_level_selector)
		ui_layer.add_child(menu_btn)
	else:
		var end_label := Label.new()
		end_label.text = "Has completat tots els packs! Felicitats!"
		end_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		end_label.add_theme_font_size_override("font_size", 20)
		end_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.8))
		end_label.position = Vector2(340, 350)
		end_label.size = Vector2(600, 40)
		end_label.add_to_group("level_ui")
		ui_layer.add_child(end_label)

func _reset_current_level() -> void:
	load_pack_level(current_pack, current_level)

# ==========================================================================
# Level selector
# ==========================================================================

var _selector_visible := false

func _show_level_selector() -> void:
	if _selector_visible:
		return
	_selector_visible = true

	# Stop current level if running
	for source in sources:
		source.stop()

	# Dark overlay
	var overlay := ColorRect.new()
	overlay.name = "SelectorOverlay"
	overlay.color = Color(0.05, 0.05, 0.08, 0.92)
	overlay.position = Vector2.ZERO
	overlay.size = Vector2(1280, 720)
	overlay.add_to_group("selector_ui")
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	ui_layer.add_child(overlay)

	# Title
	var title := Label.new()
	title.text = "SumSum"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", Color(0.4, 0.8, 0.5))
	title.position = Vector2(0, 20)
	title.size = Vector2(1280, 50)
	title.add_to_group("selector_ui")
	ui_layer.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Selecciona un nivell"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 16)
	subtitle.add_theme_color_override("font_color", Color(1, 1, 1, 0.5))
	subtitle.position = Vector2(0, 60)
	subtitle.size = Vector2(1280, 30)
	subtitle.add_to_group("selector_ui")
	ui_layer.add_child(subtitle)

	# Scroll container for packs and levels
	var scroll := ScrollContainer.new()
	scroll.position = Vector2(100, 100)
	scroll.size = Vector2(1080, 560)
	scroll.add_to_group("selector_ui")
	ui_layer.add_child(scroll)

	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 12)
	scroll.add_child(vbox)

	for pack_idx in range(all_packs.size()):
		var pack: Dictionary = all_packs[pack_idx]
		var pack_levels: Array = pack.get("levels", [])

		# Pack header with completion count
		var completed: int = SaveManager.get_completed_count(pack_idx)
		var total: int = pack_levels.size()
		var pack_label := Label.new()
		pack_label.text = "%s  (%d/%d)" % [pack.get("title", "Pack %d" % (pack_idx + 1)), completed, total]
		pack_label.add_theme_font_size_override("font_size", 20)
		var header_color := Color(0.5, 0.95, 0.6) if completed >= total else Color(0.7, 0.85, 1.0)
		pack_label.add_theme_color_override("font_color", header_color)
		vbox.add_child(pack_label)

		# Level buttons in a flow
		var hflow := HFlowContainer.new()
		hflow.add_theme_constant_override("h_separation", 6)
		hflow.add_theme_constant_override("v_separation", 6)
		vbox.add_child(hflow)

		for level_idx in range(pack_levels.size()):
			var lvl: Dictionary = pack_levels[level_idx]
			var is_done: bool = SaveManager.is_level_complete(pack_idx, level_idx)
			var btn := Button.new()
			btn.text = ("✓ " if is_done else "") + str(level_idx + 1)
			btn.tooltip_text = lvl.get("title", "")
			btn.custom_minimum_size = Vector2(48, 40)
			if is_done:
				btn.add_theme_color_override("font_color", Color(0.4, 0.9, 0.5))
			btn.pressed.connect(_on_level_selected.bind(pack_idx, level_idx))
			hflow.add_child(btn)

		# Separator
		var sep := HSeparator.new()
		sep.add_theme_constant_override("separation", 8)
		vbox.add_child(sep)

func _hide_level_selector() -> void:
	_selector_visible = false
	for child in ui_layer.get_children():
		if child.is_in_group("selector_ui"):
			child.queue_free()

func _on_level_selected(pack_idx: int, level_idx: int) -> void:
	_hide_level_selector()
	load_pack_level(pack_idx, level_idx)
	AudioManager.play_music()
