class_name BoardInput
extends RefCounted

## Input event handling: mouse, keyboard, drag state for conveyors and deletion.

const ZOOM_MIN := Vector2(0.25, 0.25)
const ZOOM_MAX := Vector2(3.0, 3.0)
const ZOOM_STEP := 1.1
const PAN_SPEED := 400.0  # Pixels per second for keyboard pan

var board: Node2D  # GameBoard reference

# Conveyor drag (left-click)
var is_dragging := false
var drag_path: Array[Vector2i] = []
var drag_preview_nodes: Array[Conveyor] = []

# Delete drag (right-click)
var is_delete_dragging := false
var delete_selection: Array[Vector2i] = []

# Camera pan (middle-click)
var is_panning := false

func _init(p_board: Node2D) -> void:
	board = p_board

# ==========================================================================
# Per-frame keyboard pan
# ==========================================================================

func process_pan(delta: float) -> void:
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
		board.camera.position += pan_dir.normalized() * PAN_SPEED * delta / board.camera.zoom.x
		board.queue_redraw()

# ==========================================================================
# Main input dispatcher
# ==========================================================================

func handle_input(event: InputEvent) -> void:
	# Block all game input when level is complete or selector is open
	if board.level_complete or board.levels.selector_visible:
		return

	if event is InputEventMouseMotion:
		if is_panning:
			board.camera.position -= event.relative / board.camera.zoom
			board.queue_redraw()
			return
		var world_pos: Vector2 = board.screen_to_world(event.position)
		board.hover_cell = Constants.world_to_grid(world_pos)
		if is_dragging:
			extend_drag_path(board.hover_cell)
		if is_delete_dragging:
			extend_delete_selection(board.hover_cell)
		board.queue_redraw()

	if event is InputEventMouseButton:
		# Zoom
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			zoom_at(event.position, ZOOM_STEP)
			return
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			zoom_at(event.position, 1.0 / ZOOM_STEP)
			return
		# Pan
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			is_panning = event.pressed
			return
		# Left click
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if event.position.y > 620:
					handle_toolbar_click(event.position)
				else:
					handle_left_press(board.screen_to_world(event.position))
			else:
				handle_left_release()
		# Right click
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				handle_right_press(board.screen_to_world(event.position))
			else:
				handle_right_release()

	# Tool shortcuts (1-5)
	if event is InputEventKey and event.pressed and not event.echo:
		var key: int = event.keycode
		if key >= KEY_1 and key <= KEY_5:
			var idx: int = key - KEY_1
			if idx < BoardDrawing.TOOLBAR_TOOLS.size():
				try_select_tool(idx)

	if event.is_action_pressed("rotate"):
		handle_rotate()

	if event.is_action_pressed("ui_cancel"):
		if is_dragging:
			cancel_drag()
		if is_delete_dragging:
			cancel_delete_drag()

# ==========================================================================
# Camera zoom
# ==========================================================================

func zoom_at(screen_pos: Vector2, factor: float) -> void:
	var old_world: Vector2 = board.screen_to_world(screen_pos)
	board.camera.zoom = (board.camera.zoom * factor).clamp(ZOOM_MIN, ZOOM_MAX)
	var new_world: Vector2 = board.screen_to_world(screen_pos)
	board.camera.position += old_world - new_world
	board.queue_redraw()

# ==========================================================================
# Click handlers
# ==========================================================================

func handle_left_press(world_pos: Vector2) -> void:
	var cell := Constants.world_to_grid(world_pos)
	if not Constants.is_valid_cell(cell):
		return

	if board.current_tool == Constants.ToolMode.CONVEYOR:
		is_dragging = true
		drag_path = [cell]
		rebuild_drag_preview()
		board.queue_redraw()
	elif board.current_tool in [Constants.ToolMode.OPERATOR_ADD, Constants.ToolMode.OPERATOR_SUB,
			Constants.ToolMode.OPERATOR_MUL, Constants.ToolMode.OPERATOR_DIV]:
		var op_type: int = board.placement.tool_to_op_type(board.current_tool)
		board.placement.place_operator(cell, op_type, board.current_direction, false)

func handle_left_release() -> void:
	if is_dragging:
		if board.current_tool == Constants.ToolMode.CONVEYOR:
			finish_conveyor_drag()
		is_dragging = false
		drag_path.clear()
		clear_drag_preview()
		board.queue_redraw()

func handle_right_press(world_pos: Vector2) -> void:
	var cell := Constants.world_to_grid(world_pos)
	if not Constants.is_valid_cell(cell):
		return
	if is_dragging:
		cancel_drag()
		return

	if board.grid_mgr.has_cell(cell):
		var node: Node2D = board.grid_mgr.get_node_at(cell)
		if not node.get("is_fixed"):
			is_delete_dragging = true
			delete_selection = [cell]
			board.queue_redraw()

func handle_right_release() -> void:
	if is_delete_dragging:
		for cell in delete_selection:
			board.placement.delete_at(cell)
		is_delete_dragging = false
		delete_selection.clear()
		board.queue_redraw()

func handle_rotate() -> void:
	if Constants.is_valid_cell(board.hover_cell) and board.grid_mgr.has_cell(board.hover_cell):
		var node: Node2D = board.grid_mgr.get_node_at(board.hover_cell)
		if node.has_method("rotate_cw") and not node.get("is_fixed"):
			node.rotate_cw()
			board.grid_mgr.update_neighbor_inputs(board.hover_cell)
			AudioManager.play_sfx("rotate")
			return
	board.current_direction = Constants.next_direction(board.current_direction)
	board.queue_redraw()

# ==========================================================================
# Toolbar selection
# ==========================================================================

func try_select_tool(idx: int) -> void:
	var available: Array = board.level_data.get("available_tools", [])
	var tool_id: int = BoardDrawing.TOOLBAR_TOOLS[idx]
	if tool_id in available and not board.placement.is_tool_exhausted(tool_id):
		board.current_tool = tool_id
		board.queue_redraw()
		board.drawing.redraw_toolbar()

func handle_toolbar_click(pos: Vector2) -> void:
	var available: Array = board.level_data.get("available_tools", [])
	var btn_size := 70.0
	var spacing := 10.0
	var start_x := 200.0

	for i in range(BoardDrawing.TOOLBAR_TOOLS.size()):
		var x: float = start_x + i * (btn_size + spacing)
		if pos.x >= x and pos.x <= x + btn_size and pos.y >= 632 and pos.y <= 702:
			var tool_id: int = BoardDrawing.TOOLBAR_TOOLS[i]
			if tool_id in available and not board.placement.is_tool_exhausted(tool_id):
				board.current_tool = tool_id
				board.queue_redraw()
				board.drawing.redraw_toolbar()
			return

# ==========================================================================
# Conveyor drag
# ==========================================================================

func extend_drag_path(cell: Vector2i) -> void:
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
			trace_line_to(cell)
			changed = true

	if changed:
		rebuild_drag_preview()

func trace_line_to(target: Vector2i) -> void:
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

func finish_conveyor_drag() -> void:
	if drag_path.size() == 1:
		board.placement.place_conveyor(drag_path[0], board.current_direction)
		return

	for i in range(drag_path.size()):
		var cell: Vector2i = drag_path[i]
		var dir: int
		if i < drag_path.size() - 1:
			dir = board.placement.direction_between(drag_path[i], drag_path[i + 1])
		else:
			dir = board.placement.direction_between(drag_path[i - 1], drag_path[i])
		if i == 0 and board.grid_mgr.has_cell(cell) \
				and board.grid_mgr.get_cell_type(cell) == Constants.ComponentType.CONVEYOR:
			# First cell already has a conveyor → branch/split
			board.placement.place_split(cell, dir)
		else:
			board.placement.place_conveyor(cell, dir)

func cancel_drag() -> void:
	is_dragging = false
	drag_path.clear()
	clear_drag_preview()
	board.queue_redraw()

# --- Drag preview ---

func rebuild_drag_preview() -> void:
	clear_drag_preview()

	for i in range(drag_path.size()):
		var cell: Vector2i = drag_path[i]
		if board.grid_mgr.has_cell(cell) and board.grid_mgr.get_cell_type(cell) != Constants.ComponentType.CONVEYOR:
			continue

		var dir: int
		if drag_path.size() == 1:
			dir = board.current_direction
		elif i < drag_path.size() - 1:
			dir = board.placement.direction_between(drag_path[i], drag_path[i + 1])
		else:
			dir = board.placement.direction_between(drag_path[i - 1], drag_path[i])

		var conv := Conveyor.new()
		board.add_child(conv)
		conv.setup(cell, dir)
		conv.modulate.a = 0.5
		conv.z_index = 5

		if i > 0:
			var input_side: int = board.placement.direction_between(drag_path[i], drag_path[i - 1])
			conv.set_input_direction(input_side)

		drag_preview_nodes.append(conv)

func clear_drag_preview() -> void:
	for node in drag_preview_nodes:
		if is_instance_valid(node):
			node.queue_free()
	drag_preview_nodes.clear()

# ==========================================================================
# Delete drag
# ==========================================================================

func extend_delete_selection(cell: Vector2i) -> void:
	if not Constants.is_valid_cell(cell):
		return
	if cell in delete_selection:
		return
	if not board.grid_mgr.has_cell(cell):
		return
	var node: Node2D = board.grid_mgr.get_node_at(cell)
	if node.get("is_fixed"):
		return
	delete_selection.append(cell)
	board.queue_redraw()

func cancel_delete_drag() -> void:
	is_delete_dragging = false
	delete_selection.clear()
	board.queue_redraw()
