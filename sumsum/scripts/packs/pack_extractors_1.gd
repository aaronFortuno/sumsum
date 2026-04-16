class_name PackExtractors1

static func get_pack() -> Dictionary:
	return {
		"id": "extractors_1",
		"title": "Des de l'1",
		"description": "Només tens extractors d'1. Construeix-ho tot!",
		"difficulty": Packs.Difficulty.MEDIUM,
		"target_age": [11, 14],
		"color": Color(0.2, 0.7, 0.5),
		"levels": _get_levels(),
	}

static func _get_levels() -> Array[Dictionary]:
	return [
		# --- 1. Primers passos amb 1 ---
		{
			"title": "Quatre",
			"description": "Construeix el 4 a partir d'uns.",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 1), "value": 1, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 3), "value": 1, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 5), "value": 1, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(3, 0), "value": 1, "dir": Constants.Direction.DOWN},
				{"pos": Vector2i(6, 0), "value": 1, "dir": Constants.Direction.DOWN},
				{"pos": Vector2i(9, 0), "value": 1, "dir": Constants.Direction.DOWN},
				{"pos": Vector2i(3, 6), "value": 1, "dir": Constants.Direction.UP},
				{"pos": Vector2i(6, 6), "value": 1, "dir": Constants.Direction.UP},
			],
			"targets": [
				{"pos": Vector2i(11, 3), "value": 4},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
				Constants.ToolMode.OPERATOR_MUL,
			],
			"hint": "1+1=2, 2×2=4. Només calen 2 operadors!",
		},
		# --- 2. Vuit ---
		{
			"title": "Vuit",
			"description": "Construeix el 8.",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 0), "value": 1, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 2), "value": 1, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 4), "value": 1, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 6), "value": 1, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(4, 0), "value": 1, "dir": Constants.Direction.DOWN},
				{"pos": Vector2i(7, 0), "value": 1, "dir": Constants.Direction.DOWN},
				{"pos": Vector2i(4, 6), "value": 1, "dir": Constants.Direction.UP},
				{"pos": Vector2i(7, 6), "value": 1, "dir": Constants.Direction.UP},
				{"pos": Vector2i(11, 1), "value": 1, "dir": Constants.Direction.LEFT},
				{"pos": Vector2i(11, 5), "value": 1, "dir": Constants.Direction.LEFT},
			],
			"targets": [
				{"pos": Vector2i(11, 3), "value": 8},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
				Constants.ToolMode.OPERATOR_MUL,
			],
			"hint": "1+1=2, 2×2=4, 4×2=8. O bé: 2×2×2=8.",
		},
		# --- 3. Dotze ---
		{
			"title": "Dotze",
			"description": "Construeix el 12 des de zero.",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 1), "value": 1, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 3), "value": 1, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 5), "value": 1, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(3, 0), "value": 1, "dir": Constants.Direction.DOWN},
				{"pos": Vector2i(6, 0), "value": 1, "dir": Constants.Direction.DOWN},
				{"pos": Vector2i(9, 0), "value": 1, "dir": Constants.Direction.DOWN},
				{"pos": Vector2i(3, 6), "value": 1, "dir": Constants.Direction.UP},
				{"pos": Vector2i(6, 6), "value": 1, "dir": Constants.Direction.UP},
				{"pos": Vector2i(9, 6), "value": 1, "dir": Constants.Direction.UP},
				{"pos": Vector2i(11, 1), "value": 1, "dir": Constants.Direction.LEFT},
				{"pos": Vector2i(11, 5), "value": 1, "dir": Constants.Direction.LEFT},
			],
			"targets": [
				{"pos": Vector2i(8, 3), "value": 12},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
				Constants.ToolMode.OPERATOR_MUL,
			],
			"hint": "1+1=2, 2+1=3, 2×2=4, 3×4=12. Pensa en factors!",
		},
		# --- 4. Setze ---
		{
			"title": "Setze",
			"description": "Construeix 16. Pensa en potències!",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 0), "value": 1, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 2), "value": 1, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 4), "value": 1, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 6), "value": 1, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(5, 0), "value": 1, "dir": Constants.Direction.DOWN},
				{"pos": Vector2i(8, 0), "value": 1, "dir": Constants.Direction.DOWN},
				{"pos": Vector2i(5, 6), "value": 1, "dir": Constants.Direction.UP},
				{"pos": Vector2i(8, 6), "value": 1, "dir": Constants.Direction.UP},
			],
			"targets": [
				{"pos": Vector2i(11, 3), "value": 16},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
				Constants.ToolMode.OPERATOR_MUL,
			],
			"hint": "1+1=2, 2×2=4, 4×4=16. Tres operadors!",
		},
		# --- 5. Vint-i-cinc ---
		{
			"title": "Vint-i-cinc",
			"description": "Construeix 25. Necessitaràs un 5...",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 0), "value": 1, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 2), "value": 1, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 4), "value": 1, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 6), "value": 1, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(4, 0), "value": 1, "dir": Constants.Direction.DOWN},
				{"pos": Vector2i(7, 0), "value": 1, "dir": Constants.Direction.DOWN},
				{"pos": Vector2i(4, 6), "value": 1, "dir": Constants.Direction.UP},
				{"pos": Vector2i(7, 6), "value": 1, "dir": Constants.Direction.UP},
				{"pos": Vector2i(10, 0), "value": 1, "dir": Constants.Direction.DOWN},
				{"pos": Vector2i(10, 6), "value": 1, "dir": Constants.Direction.UP},
			],
			"targets": [
				{"pos": Vector2i(11, 3), "value": 25},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
				Constants.ToolMode.OPERATOR_MUL,
			],
			"hint": "1+1=2, 2+1=3, 3+2=5, 5×5=25. O: 2+3=5, 5×5=25.",
		},
		# --- 6. Trenta-sis ---
		{
			"title": "Trenta-sis",
			"description": "36 = 6². Però com fas un 6 amb uns?",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 1), "value": 1, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 3), "value": 1, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 5), "value": 1, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(3, 0), "value": 1, "dir": Constants.Direction.DOWN},
				{"pos": Vector2i(6, 0), "value": 1, "dir": Constants.Direction.DOWN},
				{"pos": Vector2i(9, 0), "value": 1, "dir": Constants.Direction.DOWN},
				{"pos": Vector2i(3, 6), "value": 1, "dir": Constants.Direction.UP},
				{"pos": Vector2i(6, 6), "value": 1, "dir": Constants.Direction.UP},
				{"pos": Vector2i(9, 6), "value": 1, "dir": Constants.Direction.UP},
				{"pos": Vector2i(11, 2), "value": 1, "dir": Constants.Direction.LEFT},
				{"pos": Vector2i(11, 4), "value": 1, "dir": Constants.Direction.LEFT},
			],
			"targets": [
				{"pos": Vector2i(8, 3), "value": 36},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
				Constants.ToolMode.OPERATOR_MUL,
			],
			"hint": "1+1=2, 2+1=3, 2×3=6, 6×6=36.",
		},
	]
