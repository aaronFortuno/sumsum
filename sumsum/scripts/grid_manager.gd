class_name GridManager
extends RefCounted

## Manages the grid state: cell storage, conveyor input calculations,
## and dynamic connection discovery for operators / components.

var grid: Dictionary = {}  # Vector2i → { "type": int, "node": Node2D }

# ==========================================================================
# Cell access
# ==========================================================================

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

# ==========================================================================
# Conveyor input recalculation
# ==========================================================================

## Recalculate inputs for this cell and all neighbors, then update
## component connections.
func update_neighbor_inputs(cell: Vector2i) -> void:
	_recalc_input(cell)
	for dir in range(4):
		var neighbor_pos: Vector2i = cell + Constants.DIR_VECTORS[dir]
		_recalc_input(neighbor_pos)
	_update_neighbors_connections(cell)

## Recalculate inputs for all neighbors of [cell] (after deletion).
func recalc_neighbors(cell: Vector2i) -> void:
	for dir in range(4):
		var neighbor_pos: Vector2i = cell + Constants.DIR_VECTORS[dir]
		_recalc_input(neighbor_pos)
		_update_component_inputs(neighbor_pos)

## Scan all neighbors of [cell] that output toward it, and register
## them as input directions. Supports multiple inputs (merge).
func _recalc_input(cell: Vector2i) -> void:
	if not has_cell(cell) or grid[cell]["type"] != Constants.ComponentType.CONVEYOR:
		return
	var conv: Conveyor = grid[cell]["node"]
	conv.clear_input_directions()
	for dir in range(4):
		var neighbor_pos: Vector2i = cell + Constants.DIR_VECTORS[dir]
		if not has_cell(neighbor_pos):
			continue
		var n_data: Dictionary = grid[neighbor_pos]
		# Crossing neighbor: outputs toward us if it has input from our side
		if n_data["type"] == Constants.ComponentType.CONVEYOR:
			var n_conv: Conveyor = n_data["node"]
			if n_conv.is_crossing:
				if dir in n_conv.input_directions:
					conv.add_input_direction(dir)
				continue
		# Splitter neighbor: outputs toward us if we're in its output_sides
		if n_data["type"] == Constants.ComponentType.SPLITTER:
			var n_spl: SplitterBlock = n_data["node"]
			if dir in n_spl.output_sides:
				conv.add_input_direction(dir)
			continue
		# Normal case: check if neighbor's output direction points to cell
		var n_dir := -1
		if n_data["type"] == Constants.ComponentType.CONVEYOR:
			n_dir = (n_data["node"] as Conveyor).direction
		elif n_data["type"] == Constants.ComponentType.SOURCE:
			n_dir = (n_data["node"] as NumberSource).direction
		elif n_data["type"] == Constants.ComponentType.OPERATOR:
			n_dir = (n_data["node"] as OperatorBlock).direction
		if n_dir >= 0:
			var n_target: Vector2i = neighbor_pos + Constants.DIR_VECTORS[n_dir]
			if n_target == cell:
				conv.add_input_direction(dir)

# ==========================================================================
# Component connection discovery
# ==========================================================================

## Call after placing a component to discover its initial connections.
func update_cell_connections(cell: Vector2i) -> void:
	_update_component_inputs(cell)
	_update_splitter_connections(cell)

## Scan neighbors of [cell] for components that need connection updates.
func _update_neighbors_connections(cell: Vector2i) -> void:
	for dir in range(4):
		var neighbor_pos: Vector2i = cell + Constants.DIR_VECTORS[dir]
		_update_component_inputs(neighbor_pos)
		_update_splitter_connections(neighbor_pos)

## Discover which neighboring conveyors point TO [cell] (operator inputs).
func _update_component_inputs(cell: Vector2i) -> void:
	if not has_cell(cell):
		return
	var data: Dictionary = grid[cell]
	if data["type"] != Constants.ComponentType.OPERATOR:
		return

	var node: Node2D = data["node"]
	if not node.has_method("update_input_connections"):
		return

	var input_sides: Array = []
	for dir in range(4):
		var neighbor_pos: Vector2i = cell + Constants.DIR_VECTORS[dir]
		if not has_cell(neighbor_pos):
			continue
		var n_data: Dictionary = grid[neighbor_pos]
		if n_data["type"] == Constants.ComponentType.CONVEYOR:
			var n_conv: Conveyor = n_data["node"]
			var n_target: Vector2i = neighbor_pos + Constants.DIR_VECTORS[n_conv.direction]
			if n_target == cell:
				input_sides.append(dir)
		elif n_data["type"] == Constants.ComponentType.SOURCE:
			var source: NumberSource = n_data["node"]
			var s_target: Vector2i = neighbor_pos + Constants.DIR_VECTORS[source.direction]
			if s_target == cell:
				input_sides.append(dir)

	(node as OperatorBlock).update_input_connections(input_sides)

## Discover splitter input (conveyor pointing TO it) and outputs
## (conveyors receiving FROM it).
func _update_splitter_connections(cell: Vector2i) -> void:
	if not has_cell(cell):
		return
	var data: Dictionary = grid[cell]
	if data["type"] != Constants.ComponentType.SPLITTER:
		return

	var splitter: SplitterBlock = data["node"]
	var in_side: int = -1
	var out_sides: Array = []

	for dir in range(4):
		var neighbor_pos: Vector2i = cell + Constants.DIR_VECTORS[dir]
		if not has_cell(neighbor_pos):
			continue
		var n_data: Dictionary = grid[neighbor_pos]
		if n_data["type"] != Constants.ComponentType.CONVEYOR:
			continue
		var n_conv: Conveyor = n_data["node"]
		var n_target: Vector2i = neighbor_pos + Constants.DIR_VECTORS[n_conv.direction]

		if n_target == cell:
			# This conveyor points TO us → input
			in_side = dir
		elif Constants.opposite_dir(dir) in n_conv.input_directions:
			# This conveyor receives FROM our side → output
			out_sides.append(dir)

	splitter.update_connections(in_side, out_sides)
