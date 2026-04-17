class_name BoardRouting
extends RefCounted

## Ball routing and simulation.
## Operates on the GameBoard's number_balls, occupied_cells, and grid state.

var board: Node2D  # GameBoard reference

func _init(p_board: Node2D) -> void:
	board = p_board

# ==========================================================================
# Signal handlers (called by sources/operators)
# ==========================================================================

func on_source_emit(value: float, source_pos: Vector2i, dir: int) -> void:
	var next_pos: Vector2i = source_pos + Constants.DIR_VECTORS[dir]
	if is_cell_blocked(next_pos, source_pos):
		return
	spawn_ball(value, source_pos, next_pos)

func on_operator_result(value: float, op_pos: Vector2i, dir: int) -> void:
	var next_pos: Vector2i = op_pos + Constants.DIR_VECTORS[dir]
	spawn_ball(value, op_pos, next_pos)
	# Operator slots are now free — resume waiting balls
	try_resume_behind(op_pos)

func on_target_reached(_target: TargetBlock, _value: float, _is_correct: bool) -> void:
	board.queue_redraw()

# ==========================================================================
# Ball lifecycle
# ==========================================================================

func spawn_ball(value: float, from_pos: Vector2i, to_pos: Vector2i) -> void:
	var ball: NumberBall = board.ball_scene.instantiate()
	board.add_child(ball)
	ball.setup(value, from_pos)
	ball.arrived.connect(on_ball_arrived)
	board.number_balls.append(ball)

	if is_cell_blocked(to_pos, from_pos):
		destroy_ball(ball)
		return

	route_ball(ball, to_pos)

func on_ball_arrived(ball: NumberBall, grid_pos: Vector2i) -> void:
	if not is_instance_valid(ball):
		return

	if not board.grid_mgr.has_cell(grid_pos):
		destroy_ball(ball)
		return

	var data: Dictionary = board.grid_mgr.get_cell(grid_pos)
	match data["type"]:
		Constants.ComponentType.CONVEYOR:
			var conv: Conveyor = data["node"]
			var output_dir: int
			if conv.is_splitter():
				output_dir = conv.peek_next_output()
			else:
				output_dir = conv.get_output_for(ball.from_direction)
			var next_pos: Vector2i = grid_pos + Constants.DIR_VECTORS[output_dir]
			if is_cell_blocked(next_pos, grid_pos):
				stop_ball(ball)
				return
			if conv.is_splitter():
				conv.advance_output()
			route_ball(ball, next_pos)

		Constants.ComponentType.OPERATOR:
			var op: OperatorBlock = data["node"]
			op.receive_number(ball.value, ball.from_direction)
			destroy_ball(ball)

		Constants.ComponentType.TARGET:
			var target: TargetBlock = data["node"]
			target.receive_number(ball.value)
			destroy_ball(ball)
			board.check_win()

		Constants.ComponentType.SOURCE:
			destroy_ball(ball)

func route_ball(ball: NumberBall, cell_pos: Vector2i) -> void:
	if not board.grid_mgr.has_cell(cell_pos):
		stop_ball(ball)
		return

	var data: Dictionary = board.grid_mgr.get_cell(cell_pos)
	var half: float = float(Constants.CELL_SIZE) / 2.0

	match data["type"]:
		Constants.ComponentType.CONVEYOR:
			var conv: Conveyor = data["node"]
			if conv.is_splitter():
				ball.move_to(cell_pos)
			else:
				var entry_side: int = direction_between(cell_pos, ball.grid_pos)
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
			destroy_ball(ball)

# ==========================================================================
# Queue system (stopped balls)
# ==========================================================================

func is_cell_blocked(cell_pos: Vector2i, from_cell: Vector2i = Vector2i(-999, -999)) -> bool:
	if not Constants.is_valid_cell(cell_pos):
		return true
	if not board.grid_mgr.has_cell(cell_pos):
		return true
	if board.occupied_cells.has(cell_pos):
		return true
	# Check operator capacity
	if from_cell != Vector2i(-999, -999) and board.grid_mgr.has_cell(cell_pos):
		var data: Dictionary = board.grid_mgr.get_cell(cell_pos)
		if data["type"] == Constants.ComponentType.OPERATOR:
			var op: OperatorBlock = data["node"]
			var entry_side: int = direction_between(cell_pos, from_cell)
			if not op.can_receive(entry_side):
				return true
	return false

func stop_ball(ball: NumberBall) -> void:
	board.occupied_cells[ball.grid_pos] = ball

func resume_ball(ball: NumberBall) -> void:
	var old_cell: Vector2i = ball.grid_pos
	board.occupied_cells.erase(old_cell)
	on_ball_arrived(ball, old_cell)
	try_resume_behind(old_cell)

func try_resume_behind(freed_cell: Vector2i) -> void:
	for dir in range(4):
		var neighbor: Vector2i = freed_cell + Constants.DIR_VECTORS[dir]
		if not board.occupied_cells.has(neighbor):
			continue
		var waiting_ball: NumberBall = board.occupied_cells[neighbor]
		if not is_instance_valid(waiting_ball):
			board.occupied_cells.erase(neighbor)
			continue
		var conv: Conveyor = board.grid_mgr.get_conveyor(neighbor)
		if conv == null:
			continue
		# Check if this ball could go to the freed cell
		var would_go_here := false
		if conv.is_splitter():
			for out_dir in conv.get_all_outputs():
				if neighbor + Constants.DIR_VECTORS[out_dir] == freed_cell:
					would_go_here = true
					break
		else:
			var output_dir: int = conv.get_output_for(waiting_ball.from_direction)
			would_go_here = (neighbor + Constants.DIR_VECTORS[output_dir] == freed_cell)
		if would_go_here:
			delayed_resume(waiting_ball)
			return

func delayed_resume(ball: NumberBall) -> void:
	await board.get_tree().create_timer(0.12).timeout
	if is_instance_valid(ball) and board.occupied_cells.has(ball.grid_pos):
		resume_ball(ball)

func destroy_ball(ball: NumberBall) -> void:
	if is_instance_valid(ball):
		board.occupied_cells.erase(ball.grid_pos)
		board.number_balls.erase(ball)
		ball.queue_free()

# ==========================================================================
# Helpers
# ==========================================================================

func direction_between(from: Vector2i, to: Vector2i) -> int:
	var delta := to - from
	if delta.x > 0: return Constants.Direction.RIGHT
	if delta.x < 0: return Constants.Direction.LEFT
	if delta.y > 0: return Constants.Direction.DOWN
	return Constants.Direction.UP
