class_name BoardDrawing
extends RefCounted

## Grid drawing, hover/delete overlays, toolbar visuals.

## Fixed tool order — always shown in toolbar
const TOOLBAR_TOOLS: Array[int] = [
	Constants.ToolMode.CONVEYOR,
	Constants.ToolMode.OPERATOR_ADD,
	Constants.ToolMode.OPERATOR_SUB,
	Constants.ToolMode.OPERATOR_MUL,
	Constants.ToolMode.OPERATOR_DIV,
]

const TOOL_SYMBOLS := {
	Constants.ToolMode.CONVEYOR: "⇢",
	Constants.ToolMode.OPERATOR_ADD: "+",
	Constants.ToolMode.OPERATOR_SUB: "−",
	Constants.ToolMode.OPERATOR_MUL: "×",
	Constants.ToolMode.OPERATOR_DIV: "÷",
}

const TOOL_TOOLTIPS := {
	Constants.ToolMode.CONVEYOR: "Cinta transportadora",
	Constants.ToolMode.OPERATOR_ADD: "Sumador",
	Constants.ToolMode.OPERATOR_SUB: "Restador",
	Constants.ToolMode.OPERATOR_MUL: "Multiplicador",
	Constants.ToolMode.OPERATOR_DIV: "Divisor",
}

var board: Node2D  # GameBoard reference
var toolbar_draw_node: Node2D

func _init(p_board: Node2D) -> void:
	board = p_board

# ==========================================================================
# World-space drawing (called from GameBoard._draw)
# ==========================================================================

func draw_world() -> void:
	# Background (large enough to cover visible area at any zoom)
	var total_w: float = board.active_grid_size.x * Constants.CELL_SIZE + 2000
	var total_h: float = board.active_grid_size.y * Constants.CELL_SIZE + 2000
	board.draw_rect(Rect2(-1000, -1000, total_w, total_h), Constants.COLOR_BG, true)

	# Grid background — uses the level's grid_size
	var grid_rect := Rect2(
		Constants.GRID_OFFSET,
		Vector2(board.active_grid_size.x * Constants.CELL_SIZE, board.active_grid_size.y * Constants.CELL_SIZE)
	)
	board.draw_rect(grid_rect, Constants.COLOR_GRID_BG, true)

	# Grid lines
	for x in range(board.active_grid_size.x + 1):
		var from := Constants.GRID_OFFSET + Vector2(x * Constants.CELL_SIZE, 0)
		var to := from + Vector2(0, board.active_grid_size.y * Constants.CELL_SIZE)
		board.draw_line(from, to, Constants.COLOR_GRID_LINE, 1.0)
	for y in range(board.active_grid_size.y + 1):
		var from := Constants.GRID_OFFSET + Vector2(0, y * Constants.CELL_SIZE)
		var to := from + Vector2(board.active_grid_size.x * Constants.CELL_SIZE, 0)
		board.draw_line(from, to, Constants.COLOR_GRID_LINE, 1.0)

	# Delete selection overlay
	if board.input.is_delete_dragging:
		for cell in board.input.delete_selection:
			var world_pos := Constants.grid_to_world(cell)
			var half := Constants.CELL_SIZE / 2.0
			board.draw_rect(
				Rect2(world_pos.x - half, world_pos.y - half, Constants.CELL_SIZE, Constants.CELL_SIZE),
				Color(1, 0.15, 0.15, 0.3), true
			)

	# Hover preview (when not dragging)
	if not board.input.is_dragging and not board.input.is_delete_dragging:
		if board.current_tool != Constants.ToolMode.NONE and Constants.is_valid_cell(board.hover_cell):
			var world_pos := Constants.grid_to_world(board.hover_cell)
			var half := Constants.CELL_SIZE / 2.0
			var can_place: bool = not board.grid_mgr.has_cell(board.hover_cell)
			var hover_color: Color = Constants.COLOR_HOVER if can_place else Constants.COLOR_INVALID
			board.draw_rect(
				Rect2(world_pos.x - half, world_pos.y - half, Constants.CELL_SIZE, Constants.CELL_SIZE),
				hover_color, true
			)

# ==========================================================================
# Toolbar drawing (screen-space via CanvasLayer sub-node)
# ==========================================================================

func ensure_toolbar_draw_node() -> void:
	if toolbar_draw_node != null and is_instance_valid(toolbar_draw_node):
		return
	toolbar_draw_node = Node2D.new()
	toolbar_draw_node.name = "ToolbarDraw"
	toolbar_draw_node.draw.connect(on_toolbar_draw)
	board.ui_layer.add_child(toolbar_draw_node)

## Returns which tools the player has seen in any level up to (and including)
## the current one. Used to show "known but unavailable" vs "unknown".
func get_known_tools() -> Dictionary:
	var known := {}
	for p_idx in range(board.all_packs.size()):
		var pack: Dictionary = board.all_packs[p_idx]
		var pack_levels: Array = pack.get("levels", [])
		for l_idx in range(pack_levels.size()):
			if p_idx > board.current_pack or (p_idx == board.current_pack and l_idx > board.current_level):
				break
			for tool_id in pack_levels[l_idx].get("available_tools", []):
				known[tool_id] = true
		if p_idx > board.current_pack:
			break
	return known

func on_toolbar_draw() -> void:
	var td := toolbar_draw_node

	# Top info bar background
	td.draw_rect(Rect2(0, 0, 1280, 55), Color(0.08, 0.08, 0.1, 0.85), true)
	td.draw_line(Vector2(0, 55), Vector2(1280, 55), Constants.COLOR_GRID_LINE, 1.0)

	# Toolbar background
	td.draw_rect(Rect2(0, 620, 1280, 100), Constants.COLOR_TOOLBAR_BG, true)
	td.draw_line(Vector2(0, 620), Vector2(1280, 620), Constants.COLOR_GRID_LINE, 2.0)

	# Tool buttons — always show all 5, with states
	var available: Array = board.level_data.get("available_tools", [])
	var known: Dictionary = get_known_tools()
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
			btn_color = Color(0.12, 0.12, 0.15)
		elif not is_available:
			btn_color = Color(0.18, 0.18, 0.22)
		elif tool_id == board.current_tool:
			btn_color = Constants.COLOR_TOOLBAR_BTN_SEL
		else:
			btn_color = Constants.COLOR_TOOLBAR_BTN

		td.draw_rect(rect, btn_color, true)
		var border_color: Color = btn_color.lightened(0.15) if is_known else btn_color.lightened(0.05)
		td.draw_rect(rect, border_color, false, 1.5)

		# Shortcut number
		if is_known:
			var font: Font = ThemeDB.fallback_font
			var num_color := Color(1, 1, 1, 0.3) if is_available else Color(1, 1, 1, 0.12)
			td.draw_string(font, Vector2(x + btn_size - 14, 646), str(i + 1),
				HORIZONTAL_ALIGNMENT_LEFT, -1, 10, num_color)

func redraw_toolbar() -> void:
	if toolbar_draw_node != null and is_instance_valid(toolbar_draw_node):
		toolbar_draw_node.queue_redraw()
	# Update limit counters
	var limits: Dictionary = board.level_data.get("tool_limits", {})
	for tool_id: int in limits:
		var count_label: Label = board.ui_layer.get_node_or_null("LimitLabel_%d" % tool_id)
		if count_label:
			var used: int = board.tool_counts.get(tool_id, 0)
			var max_count: int = limits[tool_id]
			count_label.text = "%d/%d" % [used, max_count]
			count_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.6) if used < max_count else Color(1, 0.3, 0.3, 0.8))
