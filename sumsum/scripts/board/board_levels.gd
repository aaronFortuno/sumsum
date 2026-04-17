class_name BoardLevels
extends RefCounted

## Level lifecycle: setup, win condition, level selector overlay.

const CHUNK_SIZE := 10

var board: Node2D  # GameBoard reference
var selector_visible := false

func _init(p_board: Node2D) -> void:
	board = p_board

# ==========================================================================
# Level setup
# ==========================================================================

func clear_board() -> void:
	board.level_complete = false
	for source in board.sources:
		source.stop()
	board.input.clear_drag_preview()
	board.grid_mgr.clear_all()
	for ball in board.number_balls:
		if is_instance_valid(ball):
			ball.queue_free()
	board.number_balls.clear()
	board.occupied_cells.clear()
	board.sources.clear()
	board.operators.clear()
	board.targets.clear()
	board.tool_counts.clear()

	# Clear UI labels
	for child in board.ui_layer.get_children():
		if child.is_in_group("toolbar_ui") or child.is_in_group("level_ui"):
			child.queue_free()
	for child in board.get_children():
		if child.is_in_group("toolbar_ui") or child.is_in_group("level_ui"):
			child.queue_free()

func setup_level() -> void:
	# --- Targets (placed first so extractors avoid them) ---
	for t_data in board.level_data.get("targets", []):
		var target := TargetBlock.new()
		board.add_child(target)
		target.setup(t_data["pos"], t_data["value"])
		target.target_reached.connect(board.routing.on_target_reached)
		board.targets.append(target)
		board.grid_mgr.set_cell(t_data["pos"], Constants.ComponentType.TARGET, target)

	# --- Sources: static ("sources") or random ("extractors") ---
	if board.level_data.has("extractors"):
		setup_random_extractors()
	else:
		for s_data in board.level_data.get("sources", []):
			var source := NumberSource.new()
			board.add_child(source)
			source.setup(s_data["pos"], s_data["value"], s_data["dir"])
			source.number_emitted.connect(board.routing.on_source_emit)
			board.sources.append(source)
			board.grid_mgr.set_cell(s_data["pos"], Constants.ComponentType.SOURCE, source)

	# --- Fixed operators ---
	for o_data in board.level_data.get("fixed_operators", []):
		board.placement.place_operator(o_data["pos"], o_data["op"], o_data["dir"], true)

	# --- Fixed conveyors ---
	for c_data in board.level_data.get("fixed_conveyors", []):
		board.placement.place_conveyor(c_data["pos"], c_data["dir"])
		var cell_data: Dictionary = board.grid_mgr.get_cell(c_data["pos"])
		if not cell_data.is_empty():
			cell_data["node"].is_fixed = true

# ==========================================================================
# Random extractor placement (chunk-based density)
# ==========================================================================

## Scatter extractors uniformly using density-per-chunk.
## Level format: "extractors": {1: 1.0, 2: 1.5}
##   value: density as extractors per 100 cells.
func setup_random_extractors() -> void:
	var grid_size: Vector2i = board.active_grid_size
	var extractor_def: Dictionary = board.level_data.get("extractors", {})
	var occupied: Array[Vector2i] = []

	# Reserve target cells and their neighbors
	for t in board.targets:
		occupied.append(t.grid_pos)
		for dir in range(4):
			occupied.append(t.grid_pos + Constants.DIR_VECTORS[dir])

	var chunks_x: int = ceili(float(grid_size.x) / CHUNK_SIZE)
	var chunks_y: int = ceili(float(grid_size.y) / CHUNK_SIZE)

	for cx in range(chunks_x):
		for cy in range(chunks_y):
			var chunk_origin := Vector2i(cx * CHUNK_SIZE, cy * CHUNK_SIZE)
			var chunk_w: int = mini(CHUNK_SIZE, grid_size.x - chunk_origin.x)
			var chunk_h: int = mini(CHUNK_SIZE, grid_size.y - chunk_origin.y)

			for val_key in extractor_def:
				var val: float = float(val_key)
				var density: float = float(extractor_def[val_key])
				var chunk_cells: float = float(chunk_w * chunk_h)
				var expected: float = density * chunk_cells / 100.0
				var count: int = int(expected)
				if randf() < (expected - count):
					count += 1

				for _i in range(count):
					var pos := find_free_in_chunk(chunk_origin, chunk_w, chunk_h, occupied)
					if pos == Vector2i(-1, -1):
						continue
					place_extractor(pos, val)
					occupied.append(pos)

func place_extractor(pos: Vector2i, val: float) -> void:
	var source := NumberSource.new()
	board.add_child(source)
	source.setup(pos, val, Constants.Direction.RIGHT)
	source.number_emitted.connect(board.routing.on_source_emit)
	board.sources.append(source)
	board.grid_mgr.set_cell(pos, Constants.ComponentType.SOURCE, source)

func find_free_in_chunk(origin: Vector2i, w: int, h: int, occupied: Array[Vector2i]) -> Vector2i:
	var margin := 1
	var x0: int = origin.x + margin
	var y0: int = origin.y + margin
	var x1: int = origin.x + w - 1 - margin
	var y1: int = origin.y + h - 1 - margin
	if x0 > x1 or y0 > y1:
		x0 = origin.x
		y0 = origin.y
		x1 = origin.x + w - 1
		y1 = origin.y + h - 1
	for _attempt in range(50):
		var pos := Vector2i(randi_range(x0, x1), randi_range(y0, y1))
		if pos not in occupied and not board.grid_mgr.has_cell(pos):
			return pos
	return Vector2i(-1, -1)

# ==========================================================================
# Toolbar and level info UI
# ==========================================================================

func setup_toolbar() -> void:
	board.drawing.ensure_toolbar_draw_node()

	var available: Array = board.level_data.get("available_tools", [])
	var known: Dictionary = board.drawing.get_known_tools()
	var btn_size := 70.0
	var spacing := 10.0
	var start_x: float = 200.0

	for i in range(BoardDrawing.TOOLBAR_TOOLS.size()):
		var tool_id: int = BoardDrawing.TOOLBAR_TOOLS[i]
		var x: float = start_x + i * (btn_size + spacing)
		var is_available: bool = tool_id in available
		var is_known: bool = known.has(tool_id)

		var label := Label.new()
		if not is_known:
			label.text = "?"
		else:
			label.text = BoardDrawing.TOOL_SYMBOLS.get(tool_id, "?")
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 22)
		if not is_known:
			label.add_theme_color_override("font_color", Color(1, 1, 1, 0.1))
		elif not is_available:
			label.add_theme_color_override("font_color", Color(1, 1, 1, 0.25))
		else:
			label.add_theme_color_override("font_color", Color.WHITE)
		label.tooltip_text = BoardDrawing.TOOL_TOOLTIPS.get(tool_id, "") + " [%d]" % (i + 1) if is_known else ""
		label.position = Vector2(x, 632)
		label.size = Vector2(btn_size, btn_size)
		label.mouse_filter = Control.MOUSE_FILTER_PASS
		label.add_to_group("toolbar_ui")
		label.z_index = 5
		board.ui_layer.add_child(label)

		# Limit counter under button
		var limits: Dictionary = board.level_data.get("tool_limits", {})
		if is_available and limits.has(tool_id):
			var count_label := Label.new()
			count_label.name = "LimitLabel_%d" % tool_id
			var used: int = board.tool_counts.get(tool_id, 0)
			var max_count: int = limits[tool_id]
			count_label.text = "%d/%d" % [used, max_count]
			count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			count_label.add_theme_font_size_override("font_size", 11)
			count_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.6) if used < max_count else Color(1, 0.3, 0.3, 0.8))
			count_label.position = Vector2(x, 700)
			count_label.size = Vector2(btn_size, 16)
			count_label.add_to_group("toolbar_ui")
			count_label.z_index = 5
			board.ui_layer.add_child(count_label)

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
	board.ui_layer.add_child(hint_label)

	# HUD buttons (right side)
	var menu_btn := Button.new()
	menu_btn.text = "Menú"
	menu_btn.position = Vector2(1080, 640)
	menu_btn.size = Vector2(80, 30)
	menu_btn.add_to_group("toolbar_ui")
	menu_btn.pressed.connect(show_level_selector)
	board.ui_layer.add_child(menu_btn)

	var reset_btn := Button.new()
	reset_btn.text = "Reiniciar"
	reset_btn.position = Vector2(1080, 676)
	reset_btn.size = Vector2(80, 30)
	reset_btn.add_to_group("toolbar_ui")
	reset_btn.pressed.connect(reset_current_level)
	board.ui_layer.add_child(reset_btn)

func setup_level_info() -> void:
	# Pack + level title (left)
	var title_label := Label.new()
	title_label.name = "LevelTitle"
	var pack_title: String = board.all_packs[board.current_pack].get("title", "")
	title_label.text = "%s — Nivell %d: %s" % [pack_title, board.current_level + 1, board.level_data.get("title", "")]
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	title_label.add_theme_font_size_override("font_size", 14)
	title_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.6))
	title_label.position = Vector2(20, 4)
	title_label.size = Vector2(400, 22)
	title_label.add_to_group("level_ui")
	board.ui_layer.add_child(title_label)

	# Objective / description (centered, prominent)
	var desc: String = board.level_data.get("description", "")
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
		board.ui_layer.add_child(desc_label)

# ==========================================================================
# Win condition
# ==========================================================================

func check_win() -> void:
	if board.level_complete:
		return
	for t in board.targets:
		if not t.is_satisfied:
			return
	board.level_complete = true
	SaveManager.mark_level_complete(board.current_pack, board.current_level)
	AudioManager.play_sfx("win")
	on_level_complete()

func on_level_complete() -> void:
	for source in board.sources:
		source.stop()
	for ball in board.number_balls:
		if is_instance_valid(ball):
			ball.queue_free()
	board.number_balls.clear()
	board.occupied_cells.clear()
	for op in board.operators:
		op.reset_inputs()

	# Dark panel behind win message
	var panel := ColorRect.new()
	panel.color = Color(0.05, 0.08, 0.05, 0.85)
	panel.position = Vector2(290, 260)
	panel.size = Vector2(700, 160)
	panel.add_to_group("level_ui")
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	board.ui_layer.add_child(panel)

	var win_label := Label.new()
	win_label.text = "Nivell completat!"
	win_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	win_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	win_label.add_theme_font_size_override("font_size", 36)
	win_label.add_theme_color_override("font_color", Constants.COLOR_TARGET_OK)
	win_label.position = Vector2(340, 275)
	win_label.size = Vector2(600, 60)
	win_label.add_to_group("level_ui")
	board.ui_layer.add_child(win_label)

	await board.get_tree().create_timer(1.5).timeout
	var pack_levels: Array = board.all_packs[board.current_pack].get("levels", [])
	var has_next_level: bool = board.current_level + 1 < pack_levels.size()
	var has_next_pack: bool = board.current_pack + 1 < board.all_packs.size()

	if has_next_level or has_next_pack:
		var next_btn := Button.new()
		if has_next_level:
			next_btn.text = "Següent nivell"
		else:
			var next_pack_title: String = board.all_packs[board.current_pack + 1].get("title", "")
			next_btn.text = "Següent pack: %s" % next_pack_title
		next_btn.position = Vector2(515, 345)
		next_btn.size = Vector2(250, 40)
		next_btn.add_to_group("level_ui")
		next_btn.pressed.connect(func():
			if has_next_level:
				board.load_pack_level(board.current_pack, board.current_level + 1)
			else:
				board.load_pack_level(board.current_pack + 1, 0)
		)
		board.ui_layer.add_child(next_btn)

		var menu_btn := Button.new()
		menu_btn.text = "Menú"
		menu_btn.position = Vector2(515, 390)
		menu_btn.size = Vector2(250, 35)
		menu_btn.add_to_group("level_ui")
		menu_btn.pressed.connect(show_level_selector)
		board.ui_layer.add_child(menu_btn)
	else:
		var end_label := Label.new()
		end_label.text = "Has completat tots els packs! Felicitats!"
		end_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		end_label.add_theme_font_size_override("font_size", 20)
		end_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.8))
		end_label.position = Vector2(340, 350)
		end_label.size = Vector2(600, 40)
		end_label.add_to_group("level_ui")
		board.ui_layer.add_child(end_label)

func reset_current_level() -> void:
	board.load_pack_level(board.current_pack, board.current_level)

# ==========================================================================
# Level selector
# ==========================================================================

func show_level_selector() -> void:
	if selector_visible:
		return
	selector_visible = true

	for source in board.sources:
		source.stop()

	# Dark overlay
	var overlay := ColorRect.new()
	overlay.name = "SelectorOverlay"
	overlay.color = Color(0.05, 0.05, 0.08, 0.92)
	overlay.position = Vector2.ZERO
	overlay.size = Vector2(1280, 720)
	overlay.add_to_group("selector_ui")
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	board.ui_layer.add_child(overlay)

	# Title
	var title := Label.new()
	title.text = "SumSum"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", Color(0.4, 0.8, 0.5))
	title.position = Vector2(0, 20)
	title.size = Vector2(1280, 50)
	title.add_to_group("selector_ui")
	board.ui_layer.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Selecciona un nivell"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 16)
	subtitle.add_theme_color_override("font_color", Color(1, 1, 1, 0.5))
	subtitle.position = Vector2(0, 60)
	subtitle.size = Vector2(1280, 30)
	subtitle.add_to_group("selector_ui")
	board.ui_layer.add_child(subtitle)

	# Scroll container
	var scroll := ScrollContainer.new()
	scroll.position = Vector2(100, 100)
	scroll.size = Vector2(1080, 560)
	scroll.add_to_group("selector_ui")
	board.ui_layer.add_child(scroll)

	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 12)
	scroll.add_child(vbox)

	for pack_idx in range(board.all_packs.size()):
		var pack: Dictionary = board.all_packs[pack_idx]
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
			btn.pressed.connect(on_level_selected.bind(pack_idx, level_idx))
			hflow.add_child(btn)

		# Separator
		var sep := HSeparator.new()
		sep.add_theme_constant_override("separation", 8)
		vbox.add_child(sep)

func hide_level_selector() -> void:
	selector_visible = false
	for child in board.ui_layer.get_children():
		if child.is_in_group("selector_ui"):
			child.queue_free()

func on_level_selected(pack_idx: int, level_idx: int) -> void:
	hide_level_selector()
	board.load_pack_level(pack_idx, level_idx)
	AudioManager.play_music()
