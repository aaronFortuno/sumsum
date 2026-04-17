class_name BoardPlacement
extends RefCounted

## Component placement and deletion (conveyors, operators).
## Manages tool counts/limits and triggers grid manager updates.

var board: Node2D  # GameBoard reference

func _init(p_board: Node2D) -> void:
	board = p_board

# ==========================================================================
# Conveyor placement
# ==========================================================================

## Place or update a conveyor when drawing THROUGH a cell (not branching).
## Perpendicular on existing = crossing. Same axis = redirect.
func place_conveyor(cell: Vector2i, dir: int) -> void:
	if board.grid_mgr.has_cell(cell):
		var data: Dictionary = board.grid_mgr.get_cell(cell)
		if data["type"] == Constants.ComponentType.CONVEYOR:
			var conv: Conveyor = data["node"]
			if conv.is_crossing or dir == conv.direction:
				pass  # No change
			elif are_perpendicular(conv.direction, dir) and not conv.is_splitter():
				conv.is_crossing = true
			else:
				# Same axis or already a splitter: redirect
				conv.direction = dir
				conv.clear_split()
			conv.queue_redraw()
			board.grid_mgr.update_neighbor_inputs(cell)
			board.routing.try_resume_behind(cell)
		return

	var conv := Conveyor.new()
	board.add_child(conv)
	conv.setup(cell, dir)
	board.grid_mgr.set_cell(cell, Constants.ComponentType.CONVEYOR, conv)
	board.grid_mgr.update_neighbor_inputs(cell)
	board.routing.try_resume_behind(cell)
	trigger_adjacent_sources(cell)
	AudioManager.play_sfx("place")

## Branch from an existing conveyor: add a new output direction (split).
## Called only for the FIRST cell of a drag that already has a conveyor.
func place_split(cell: Vector2i, dir: int) -> void:
	var conv: Conveyor = board.grid_mgr.get_conveyor(cell)
	if conv == null:
		return
	if dir == conv.direction or dir in conv.get_all_outputs():
		return  # Already going that way
	conv.add_output_direction(dir)
	conv.queue_redraw()
	board.grid_mgr.update_neighbor_inputs(cell)
	board.routing.try_resume_behind(cell)

## If a source neighbor points to [cell], trigger an immediate emission.
func trigger_adjacent_sources(cell: Vector2i) -> void:
	for dir in range(4):
		var neighbor: Vector2i = cell + Constants.DIR_VECTORS[dir]
		if not board.grid_mgr.has_cell(neighbor):
			continue
		var n_data: Dictionary = board.grid_mgr.get_cell(neighbor)
		if n_data["type"] == Constants.ComponentType.SOURCE:
			var source: NumberSource = n_data["node"]
			if not source.is_running:
				continue
			var target: Vector2i = neighbor + Constants.DIR_VECTORS[source.direction]
			if target == cell:
				source.emit_timer = 0.0

# ==========================================================================
# Operator placement
# ==========================================================================

func place_operator(cell: Vector2i, op_type: int, dir: int, fixed: bool) -> void:
	if board.grid_mgr.has_cell(cell):
		return

	# Check tool limit for non-fixed operators
	if not fixed:
		var tool_mode: int = op_type_to_tool(op_type)
		var limits: Dictionary = board.level_data.get("tool_limits", {})
		if limits.has(tool_mode):
			var current: int = board.tool_counts.get(tool_mode, 0)
			if current >= limits[tool_mode]:
				return
		board.tool_counts[tool_mode] = board.tool_counts.get(tool_mode, 0) + 1
		board.drawing.redraw_toolbar()

	var op := OperatorBlock.new()
	board.add_child(op)
	op.setup(cell, op_type, dir, fixed)
	op.result_produced.connect(board.routing.on_operator_result)
	board.operators.append(op)
	board.grid_mgr.set_cell(cell, Constants.ComponentType.OPERATOR, op)
	board.grid_mgr.update_cell_connections(cell)
	AudioManager.play_sfx("place")

	# Auto-switch to conveyor if current tool is now exhausted
	if not fixed and is_tool_exhausted(board.current_tool):
		board.current_tool = Constants.ToolMode.CONVEYOR
		board.drawing.redraw_toolbar()

# ==========================================================================
# Deletion
# ==========================================================================

func delete_at(cell: Vector2i) -> void:
	if not board.grid_mgr.has_cell(cell):
		return
	var data: Dictionary = board.grid_mgr.get_cell(cell)
	var node: Node2D = data["node"]
	if node.get("is_fixed"):
		return

	# Destroy any ball stopped at this cell
	if board.occupied_cells.has(cell):
		board.routing.destroy_ball(board.occupied_cells[cell])

	if data["type"] == Constants.ComponentType.OPERATOR:
		var op: OperatorBlock = node
		var tool_mode: int = op_type_to_tool(op.op_type)
		board.tool_counts[tool_mode] = maxi(board.tool_counts.get(tool_mode, 0) - 1, 0)
		board.operators.erase(node)
		board.drawing.redraw_toolbar()
	node.queue_free()
	board.grid_mgr.erase_cell(cell)
	board.grid_mgr.recalc_neighbors(cell)
	AudioManager.play_sfx("delete")

# ==========================================================================
# Tool helpers
# ==========================================================================

func tool_to_op_type(tool: int) -> int:
	match tool:
		Constants.ToolMode.OPERATOR_ADD: return Constants.OperatorType.ADD
		Constants.ToolMode.OPERATOR_SUB: return Constants.OperatorType.SUBTRACT
		Constants.ToolMode.OPERATOR_MUL: return Constants.OperatorType.MULTIPLY
		Constants.ToolMode.OPERATOR_DIV: return Constants.OperatorType.DIVIDE
	return Constants.OperatorType.ADD

func op_type_to_tool(op: int) -> int:
	match op:
		Constants.OperatorType.ADD: return Constants.ToolMode.OPERATOR_ADD
		Constants.OperatorType.SUBTRACT: return Constants.ToolMode.OPERATOR_SUB
		Constants.OperatorType.MULTIPLY: return Constants.ToolMode.OPERATOR_MUL
		Constants.OperatorType.DIVIDE: return Constants.ToolMode.OPERATOR_DIV
	return Constants.ToolMode.NONE

func is_tool_exhausted(tool_id: int) -> bool:
	var limits: Dictionary = board.level_data.get("tool_limits", {})
	if not limits.has(tool_id):
		return false
	return board.tool_counts.get(tool_id, 0) >= limits[tool_id]

# ==========================================================================
# Geometry helpers
# ==========================================================================

func are_perpendicular(dir_a: int, dir_b: int) -> bool:
	return abs(dir_a - dir_b) % 2 == 1

func direction_between(from: Vector2i, to: Vector2i) -> int:
	var delta := to - from
	if delta.x > 0: return Constants.Direction.RIGHT
	if delta.x < 0: return Constants.Direction.LEFT
	if delta.y > 0: return Constants.Direction.DOWN
	return Constants.Direction.UP
