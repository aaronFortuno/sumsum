class_name GridManager
extends RefCounted

## Manages the grid state: cell storage, neighbor input calculations.
## Does NOT own nodes (game_board creates/frees them).

var grid: Dictionary = {}  # Vector2i → { "type": int, "node": Node2D }

# --- Cell access ---

func set_cell(pos: Vector2i, type: int, node: Node2D) -> void:
	grid[pos] = {"type": type, "node": node}

func has_cell(pos: Vector2i) -> bool:
	return grid.has(pos)

func get_cell(pos: Vector2i) -> Dictionary:
	return grid[pos]

func get_cell_type(pos: Vector2i) -> int:
	if grid.has(pos):
		return grid[pos]["type"] as int
	return Constants.ComponentType.NONE

func get_node_at(pos: Vector2i) -> Node2D:
	if grid.has(pos):
		return grid[pos]["node"] as Node2D
	return null

func get_conveyor(pos: Vector2i) -> Conveyor:
	if has_cell(pos) and grid[pos]["type"] == Constants.ComponentType.CONVEYOR:
		return grid[pos]["node"] as Conveyor
	return null

func erase_cell(pos: Vector2i) -> void:
	grid.erase(pos)

func clear_all() -> void:
	for cell_data in grid.values():
		var node: Node2D = cell_data["node"]
		if is_instance_valid(node):
			node.queue_free()
	grid.clear()

# --- Neighbor input logic ---

func update_neighbor_inputs(cell: Vector2i) -> void:
	# Update this cell's input_direction based on which neighbor points TO it
	if has_cell(cell) and grid[cell]["type"] == Constants.ComponentType.CONVEYOR:
		var conv: Conveyor = grid[cell]["node"]
		conv.input_direction = -1
		for dir in range(4):
			var neighbor_pos: Vector2i = cell + Constants.DIR_VECTORS[dir]
			if has_cell(neighbor_pos):
				var n_data: Dictionary = grid[neighbor_pos]
				if n_data["type"] == Constants.ComponentType.CONVEYOR:
					var n_conv: Conveyor = n_data["node"]
					var n_target: Vector2i = neighbor_pos + Constants.DIR_VECTORS[n_conv.direction]
					if n_target == cell:
						conv.set_input_direction(dir)
						break
				elif n_data["type"] == Constants.ComponentType.SOURCE:
					var source: NumberSource = n_data["node"]
					var s_target: Vector2i = neighbor_pos + Constants.DIR_VECTORS[source.direction]
					if s_target == cell:
						conv.set_input_direction(dir)
						break

	# Also update neighbors that might point to this cell or receive from it
	for dir in range(4):
		var neighbor_pos: Vector2i = cell + Constants.DIR_VECTORS[dir]
		if has_cell(neighbor_pos) and grid[neighbor_pos]["type"] == Constants.ComponentType.CONVEYOR:
			if has_cell(cell):
				var our_data: Dictionary = grid[cell]
				if our_data["type"] == Constants.ComponentType.CONVEYOR:
					var our_conv: Conveyor = our_data["node"]
					var our_target: Vector2i = cell + Constants.DIR_VECTORS[our_conv.direction]
					if our_target == neighbor_pos:
						var n_conv: Conveyor = grid[neighbor_pos]["node"]
						n_conv.set_input_direction(Constants.opposite_dir(dir))
						continue
			_recalc_input(neighbor_pos)

func recalc_neighbors(cell: Vector2i) -> void:
	for dir in range(4):
		var neighbor_pos: Vector2i = cell + Constants.DIR_VECTORS[dir]
		_recalc_input(neighbor_pos)

func _recalc_input(cell: Vector2i) -> void:
	if not has_cell(cell) or grid[cell]["type"] != Constants.ComponentType.CONVEYOR:
		return
	var conv: Conveyor = grid[cell]["node"]
	conv.input_direction = -1
	for dir in range(4):
		var neighbor_pos: Vector2i = cell + Constants.DIR_VECTORS[dir]
		if has_cell(neighbor_pos):
			var n_data: Dictionary = grid[neighbor_pos]
			var n_dir := -1
			if n_data["type"] == Constants.ComponentType.CONVEYOR:
				n_dir = (n_data["node"] as Conveyor).direction
			elif n_data["type"] == Constants.ComponentType.SOURCE:
				n_dir = (n_data["node"] as NumberSource).direction
			if n_dir >= 0:
				var n_target: Vector2i = neighbor_pos + Constants.DIR_VECTORS[n_dir]
				if n_target == cell:
					conv.set_input_direction(dir)
					return
