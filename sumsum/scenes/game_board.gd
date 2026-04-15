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

# --- Level state ---
var current_level: int = 0
var level_data: Dictionary = {}
var levels: Array[Dictionary] = []

# --- Preloaded scenes ---
var ball_scene := preload("res://scenes/components/number_ball.tscn")

func _ready() -> void:
	levels = Levels.get_all()
	load_level(0)

# ==========================================================================
# Drawing
# ==========================================================================

func _draw() -> void:
	# Background
	draw_rect(Rect2(0, 0, 1280, 720), Constants.COLOR_BG, true)

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

	# Toolbar background
	draw_rect(Rect2(0, 620, 1280, 100), Constants.COLOR_TOOLBAR_BG, true)
	draw_line(Vector2(0, 620), Vector2(1280, 620), Constants.COLOR_GRID_LINE, 2.0)

	# Toolbar buttons
	_draw_toolbar()

func _draw_toolbar() -> void:
	var tools: Array = level_data.get("available_tools", [])
	var all_tools: Array = tools.duplicate()

	var btn_size := 70.0
	var spacing := 10.0
	var start_x := 200.0

	for i in range(all_tools.size()):
		var tool_id: int = all_tools[i]
		var x: float = start_x + i * (btn_size + spacing)
		var y: float = 632.0
		var rect := Rect2(x, y, btn_size, btn_size)

		var btn_color: Color = Constants.COLOR_TOOLBAR_BTN_SEL if tool_id == current_tool else Constants.COLOR_TOOLBAR_BTN
		draw_rect(rect, btn_color, true)
		draw_rect(rect, btn_color.lightened(0.2), false, 1.5)


# ==========================================================================
# Level management
# ==========================================================================

func load_level(index: int) -> void:
	current_level = index
	if index >= levels.size():
		return
	level_data = levels[index]
	_clear_board()
	_setup_level()
	_setup_toolbar()
	_setup_level_info()
	current_tool = Constants.ToolMode.CONVEYOR
	# Simulation always running: start sources immediately
	for source in sources:
		source.start()
	queue_redraw()

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
	sources.clear()
	operators.clear()
	targets.clear()

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

func _setup_toolbar() -> void:
	var tools: Array = level_data.get("available_tools", [])
	var all_tools: Array = tools.duplicate()

	var btn_size := 70.0
	var spacing := 10.0
	var start_x: float = 200.0

	var tool_labels := {
		Constants.ToolMode.CONVEYOR: "Cinta",
		Constants.ToolMode.OPERATOR_ADD: "+",
		Constants.ToolMode.OPERATOR_SUB: "−",
		Constants.ToolMode.OPERATOR_MUL: "×",
		Constants.ToolMode.OPERATOR_DIV: "÷",
	}

	for i in range(all_tools.size()):
		var tool_id: int = all_tools[i]
		var x: float = start_x + i * (btn_size + spacing)
		var label := Label.new()
		label.text = tool_labels.get(tool_id, "?")
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 18 if tool_labels.get(tool_id, "").length() <= 2 else 11)
		label.add_theme_color_override("font_color", Color.WHITE)
		label.position = Vector2(x, 632)
		label.size = Vector2(btn_size, btn_size)
		label.add_to_group("toolbar_ui")
		label.z_index = 5
		add_child(label)

	var hint_label := Label.new()
	hint_label.name = "HintLabel"
	hint_label.text = "[R] Girar  |  Dret: Esborrar"
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hint_label.add_theme_font_size_override("font_size", 11)
	hint_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.4))
	hint_label.position = Vector2(10, 670)
	hint_label.size = Vector2(180, 30)
	hint_label.add_to_group("toolbar_ui")
	hint_label.z_index = 5
	add_child(hint_label)

func _setup_level_info() -> void:
	var title_label := Label.new()
	title_label.name = "LevelTitle"
	title_label.text = "Nivell %d: %s" % [current_level + 1, level_data.get("title", "")]
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	title_label.add_theme_font_size_override("font_size", 20)
	title_label.add_theme_color_override("font_color", Color.WHITE)
	title_label.position = Vector2(20, 8)
	title_label.size = Vector2(600, 30)
	title_label.add_to_group("level_ui")
	add_child(title_label)

	var desc_label := Label.new()
	desc_label.name = "LevelDesc"
	desc_label.text = level_data.get("description", "")
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	desc_label.add_theme_font_size_override("font_size", 13)
	desc_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.7))
	desc_label.position = Vector2(20, 32)
	desc_label.size = Vector2(800, 40)
	desc_label.add_to_group("level_ui")
	add_child(desc_label)

# ==========================================================================
# Input handling
# ==========================================================================

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		hover_cell = Constants.world_to_grid(event.position)
		if is_dragging:
			_extend_drag_path(hover_cell)
		if is_delete_dragging:
			_extend_delete_selection(hover_cell)
		queue_redraw()

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_handle_left_press(event.position)
			else:
				_handle_left_release()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				_handle_right_press(event.position)
			else:
				_handle_right_release()

	if event.is_action_pressed("rotate"):
		_handle_rotate()

	if event.is_action_pressed("ui_cancel"):
		if is_dragging:
			_cancel_drag()
		if is_delete_dragging:
			_cancel_delete_drag()

func _handle_left_press(pos: Vector2) -> void:
	if pos.y > 620:
		_handle_toolbar_click(pos)
		return

	var cell := Constants.world_to_grid(pos)
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

func _handle_left_release() -> void:
	if is_dragging:
		if current_tool == Constants.ToolMode.CONVEYOR:
			_finish_conveyor_drag()
		is_dragging = false
		drag_path.clear()
		_clear_drag_preview()
		queue_redraw()

func _handle_right_press(pos: Vector2) -> void:
	var cell := Constants.world_to_grid(pos)
	if not Constants.is_valid_cell(cell):
		return
	if is_dragging:
		_cancel_drag()
		return

	# Start delete selection if there's something deletable
	if grid_mgr.has_cell(cell):
		var node: Node2D = grid_mgr.get_node_at(cell)
		if not node.get("is_fixed"):
			is_delete_dragging = true
			delete_selection = [cell]
			queue_redraw()

func _handle_right_release() -> void:
	if is_delete_dragging:
		# Delete all selected cells
		for cell in delete_selection:
			_delete_at(cell)
		is_delete_dragging = false
		delete_selection.clear()
		queue_redraw()

func _handle_rotate() -> void:
	# If hovering over a rotatable component, rotate it
	if Constants.is_valid_cell(hover_cell) and grid_mgr.has_cell(hover_cell):
		var node: Node2D = grid_mgr.get_node_at(hover_cell)
		if node.has_method("rotate_cw") and not node.get("is_fixed"):
			node.rotate_cw()
			grid_mgr.update_neighbor_inputs(hover_cell)
			return
	# Otherwise change placement direction
	current_direction = Constants.next_direction(current_direction)
	queue_redraw()

func _handle_toolbar_click(pos: Vector2) -> void:
	var tools: Array = level_data.get("available_tools", [])

	var btn_size := 70.0
	var spacing := 10.0
	var start_x := 200.0

	for i in range(tools.size()):
		var x: float = start_x + i * (btn_size + spacing)
		if pos.x >= x and pos.x <= x + btn_size and pos.y >= 632 and pos.y <= 702:
			current_tool = tools[i]
			queue_redraw()
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

	# Backtracking: if cell is already in path, undo to that point
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

# --- Drag preview (real conveyor nodes, semi-transparent) ---

func _rebuild_drag_preview() -> void:
	_clear_drag_preview()

	for i in range(drag_path.size()):
		var cell: Vector2i = drag_path[i]
		# Skip cells occupied by non-conveyor components
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

		# Set input direction for corner detection
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
		return

	var conv := Conveyor.new()
	add_child(conv)
	conv.setup(cell, dir)
	grid_mgr.set_cell(cell, Constants.ComponentType.CONVEYOR, conv)
	grid_mgr.update_neighbor_inputs(cell)

func _place_operator(cell: Vector2i, op_type: int, dir: int, fixed: bool) -> void:
	if grid_mgr.has_cell(cell):
		return

	var op := OperatorBlock.new()
	add_child(op)
	op.setup(cell, op_type, dir, fixed)
	op.result_produced.connect(_on_operator_result)
	operators.append(op)
	grid_mgr.set_cell(cell, Constants.ComponentType.OPERATOR, op)
	grid_mgr.update_cell_connections(cell)

func _delete_at(cell: Vector2i) -> void:
	if not grid_mgr.has_cell(cell):
		return
	var data: Dictionary = grid_mgr.get_cell(cell)
	var node: Node2D = data["node"]
	if node.get("is_fixed"):
		return

	if data["type"] == Constants.ComponentType.OPERATOR:
		operators.erase(node)
	node.queue_free()
	grid_mgr.erase_cell(cell)
	grid_mgr.recalc_neighbors(cell)

func _tool_to_op_type(tool: int) -> int:
	match tool:
		Constants.ToolMode.OPERATOR_ADD: return Constants.OperatorType.ADD
		Constants.ToolMode.OPERATOR_SUB: return Constants.OperatorType.SUBTRACT
		Constants.ToolMode.OPERATOR_MUL: return Constants.OperatorType.MULTIPLY
		Constants.ToolMode.OPERATOR_DIV: return Constants.OperatorType.DIVIDE
	return Constants.OperatorType.ADD

# ==========================================================================
# Ball routing
# ==========================================================================

func _on_source_emit(value: float, source_pos: Vector2i, dir: int) -> void:
	var next_pos: Vector2i = source_pos + Constants.DIR_VECTORS[dir]
	_spawn_ball(value, source_pos, next_pos)

func _on_operator_result(value: float, op_pos: Vector2i, dir: int) -> void:
	var next_pos: Vector2i = op_pos + Constants.DIR_VECTORS[dir]
	_spawn_ball(value, op_pos, next_pos)

func _spawn_ball(value: float, from_pos: Vector2i, to_pos: Vector2i) -> void:
	var ball: NumberBall = ball_scene.instantiate()
	add_child(ball)
	ball.setup(value, from_pos)
	ball.arrived.connect(_on_ball_arrived)
	number_balls.append(ball)

	if not Constants.is_valid_cell(to_pos):
		await get_tree().create_timer(0.3).timeout
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
			if not Constants.is_valid_cell(next_pos):
				_destroy_ball(ball)
				return
			_route_ball(ball, next_pos)

		Constants.ComponentType.OPERATOR:
			var op: OperatorBlock = data["node"]
			if op.receive_number(ball.value, ball.from_direction):
				_destroy_ball(ball)
			else:
				_destroy_ball(ball)

		Constants.ComponentType.TARGET:
			var target: TargetBlock = data["node"]
			target.receive_number(ball.value)
			_destroy_ball(ball)
			_check_win()

		Constants.ComponentType.SOURCE:
			_destroy_ball(ball)

func _route_ball(ball: NumberBall, cell_pos: Vector2i) -> void:
	if not grid_mgr.has_cell(cell_pos):
		_destroy_ball(ball)
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

		Constants.ComponentType.OPERATOR, Constants.ComponentType.TARGET:
			ball.move_to(cell_pos)

		Constants.ComponentType.SOURCE:
			_destroy_ball(ball)

func _on_target_reached(_target: TargetBlock, _value: float, _is_correct: bool) -> void:
	queue_redraw()

func _destroy_ball(ball: NumberBall) -> void:
	if is_instance_valid(ball):
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
	_on_level_complete()

func _on_level_complete() -> void:
	# Pause the factory
	for source in sources:
		source.stop()
	for ball in number_balls:
		if is_instance_valid(ball):
			ball.queue_free()
	number_balls.clear()
	for op in operators:
		op.reset_inputs()
	var win_label := Label.new()
	win_label.text = "Nivell completat!"
	win_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	win_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	win_label.add_theme_font_size_override("font_size", 36)
	win_label.add_theme_color_override("font_color", Constants.COLOR_TARGET_OK)
	win_label.position = Vector2(340, 280)
	win_label.size = Vector2(600, 80)
	win_label.add_to_group("level_ui")
	add_child(win_label)

	await get_tree().create_timer(1.5).timeout
	if current_level + 1 < levels.size():
		var next_label := Label.new()
		next_label.text = "[Clic per al següent nivell]"
		next_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		next_label.add_theme_font_size_override("font_size", 18)
		next_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.8))
		next_label.position = Vector2(440, 360)
		next_label.size = Vector2(400, 40)
		next_label.add_to_group("level_ui")
		next_label.name = "NextLevelLabel"
		add_child(next_label)
		set_meta("awaiting_next", true)
	else:
		var end_label := Label.new()
		end_label.text = "Has completat tots els nivells! Felicitats!"
		end_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		end_label.add_theme_font_size_override("font_size", 20)
		end_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.8))
		end_label.position = Vector2(390, 360)
		end_label.size = Vector2(500, 40)
		end_label.add_to_group("level_ui")
		add_child(end_label)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if get_meta("awaiting_next", false):
			set_meta("awaiting_next", false)
			load_level(current_level + 1)
