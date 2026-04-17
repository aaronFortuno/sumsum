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

## Recalculate inputs and clean up outputs for all neighbors (after deletion).
func recalc_neighbors(cell: Vector2i) -> void:
	for dir in range(4):
		var neighbor_pos: Vector2i = cell + Constants.DIR_VECTORS[dir]
		_recalc_input(neighbor_pos)
		_cleanup_stale_outputs(neighbor_pos)
		_update_component_inputs(neighbor_pos)

## Remove output_directions that no longer have a valid receiving cell.
## If only one output remains, revert to normal conveyor.
func _cleanup_stale_outputs(cell: Vector2i) -> void:
	if not has_cell(cell) or grid[cell]["type"] != Constants.ComponentType.CONVEYOR:
		return
	var conv: Conveyor = grid[cell]["node"]
	if not conv.is_splitter():
		return
	var valid: Array[int] = []
	for out_dir: int in conv.output_directions:
		var target: Vector2i = cell + Constants.DIR_VECTORS[out_dir]
		if has_cell(target):
			valid.append(out_dir)
	if valid.size() <= 1:
		conv.clear_split()
		if valid.size() == 1:
			conv.direction = valid[0]
	else:
		conv.output_directions = valid
	conv.queue_redraw()

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
		if n_data["type"] == Constants.ComponentType.CONVEYOR:
			var n_conv: Conveyor = n_data["node"]
			# Crossing: outputs toward us if it has input from our side
			if n_conv.is_crossing:
				if dir in n_conv.input_directions:
					conv.add_input_direction(dir)
				continue
			# Splitter: outputs in multiple directions
			if n_conv.is_splitter():
				var needed_dir: int = Constants.opposite_dir(dir)
				if needed_dir in n_conv.get_all_outputs():
					conv.add_input_direction(dir)
				continue
			# Normal conveyor
			var n_target: Vector2i = neighbor_pos + Constants.DIR_VECTORS[n_conv.direction]
			if n_target == cell:
				conv.add_input_direction(dir)
			continue
		# Non-conveyor neighbors (source, operator)
		if n_data["type"] == Constants.ComponentType.SOURCE:
			var source: NumberSource = n_data["node"]
			for out_dir: int in source.get_all_outputs():
				var s_target: Vector2i = neighbor_pos + Constants.DIR_VECTORS[out_dir]
				if s_target == cell:
					conv.add_input_direction(dir)
		elif n_data["type"] == Constants.ComponentType.OPERATOR:
			var n_dir: int = (n_data["node"] as OperatorBlock).direction
			var n_target: Vector2i = neighbor_pos + Constants.DIR_VECTORS[n_dir]
			if n_target == cell:
				conv.add_input_direction(dir)

# ==========================================================================
# Component connection discovery
# ==========================================================================

## Call after placing a component to discover its initial connections.
func update_cell_connections(cell: Vector2i) -> void:
	_update_component_inputs(cell)

## Scan neighbors of [cell] for components that need connection updates.
func _update_neighbors_connections(cell: Vector2i) -> void:
	for dir in range(4):
		var neighbor_pos: Vector2i = cell + Constants.DIR_VECTORS[dir]
		_update_component_inputs(neighbor_pos)

## Discover which neighboring conveyors point TO [cell] (operator inputs).
func _update_component_inputs(cell: Vector2i) -> void:
	if not has_cell(cell):
		return
	var data: Dictionary = grid[cell]

	# Update operator inputs
	if data["type"] == Constants.ComponentType.OPERATOR:
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
				for out_dir: int in source.get_all_outputs():
					var s_target: Vector2i = neighbor_pos + Constants.DIR_VECTORS[out_dir]
					if s_target == cell:
						input_sides.append(dir)
		(node as OperatorBlock).update_input_connections(input_sides)

	# Update source outputs — detect adjacent conveyors that accept from us
	if data["type"] == Constants.ComponentType.SOURCE:
		var source: NumberSource = data["node"]
		var connected_sides: Array = []
		for dir in range(4):
			var neighbor_pos: Vector2i = cell + Constants.DIR_VECTORS[dir]
			if not has_cell(neighbor_pos):
				continue
			var n_data: Dictionary = grid[neighbor_pos]
			if n_data["type"] == Constants.ComponentType.CONVEYOR:
				# A conveyor next to us accepts input from our side
				# if our side is one of its input directions
				var our_side: int = Constants.opposite_dir(dir)
				# Actually: we output in direction `dir`. The conveyor at
				# neighbor_pos has us as input if it can receive from direction `dir`
				# (i.e., from the side facing us = opposite of dir).
				# For a normal conveyor, any adjacent cell outputting toward it counts.
				# We just need to check: is there a conveyor adjacent that we could feed?
				connected_sides.append(dir)
		source.update_output_connections(connected_sides)
