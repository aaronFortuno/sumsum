class_name PackExtractors3

static func get_pack() -> Dictionary:
	return {
		"id": "extractors_3",
		"title": "Extractor ×3",
		"description": "Ara tens 1, 2 i 3. Factoritza, construeix, conquesta!",
		"difficulty": Packs.Difficulty.EXPERT,
		"target_age": [13, 16],
		"color": Color(0.8, 0.3, 0.5),
		"levels": _get_levels(),
	}

static func _get_levels() -> Array[Dictionary]:
	return [
		# --- 1. Setanta-dos ---
		{
			"title": "72",
			"description": "72 = 2³ × 3² = 8 × 9. Dues branques!",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 0), "value": 2, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 2), "value": 3, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 4), "value": 2, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 6), "value": 3, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(4, 0), "value": 2, "dir": Constants.Direction.DOWN},
				{"pos": Vector2i(7, 0), "value": 1, "dir": Constants.Direction.DOWN},
				{"pos": Vector2i(4, 6), "value": 2, "dir": Constants.Direction.UP},
				{"pos": Vector2i(7, 6), "value": 3, "dir": Constants.Direction.UP},
			],
			"targets": [
				{"pos": Vector2i(11, 3), "value": 72},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_MUL,
			],
			"hint": "Branca A: 2×2×2=8. Branca B: 3×3=9. Final: 8×9=72.",
		},
		# --- 2. Dos-cents setze ---
		{
			"title": "216",
			"description": "216 = 6³. Primer fes un 6, després cub!",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 1), "value": 2, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 3), "value": 3, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 5), "value": 2, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(4, 0), "value": 3, "dir": Constants.Direction.DOWN},
				{"pos": Vector2i(7, 0), "value": 2, "dir": Constants.Direction.DOWN},
				{"pos": Vector2i(4, 6), "value": 3, "dir": Constants.Direction.UP},
				{"pos": Vector2i(7, 6), "value": 2, "dir": Constants.Direction.UP},
				{"pos": Vector2i(10, 0), "value": 3, "dir": Constants.Direction.DOWN},
				{"pos": Vector2i(10, 6), "value": 1, "dir": Constants.Direction.UP},
			],
			"targets": [
				{"pos": Vector2i(11, 3), "value": 216},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_MUL,
			],
			"hint": "2×3=6, 6×6=36, 36×6=216.",
		},
		# --- 3. Tres-cents ---
		{
			"title": "300",
			"description": "300 = 2² × 3 × 5². Però no tens 5... construeix-lo!",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 0), "value": 2, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 2), "value": 3, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 4), "value": 2, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 6), "value": 3, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(5, 0), "value": 2, "dir": Constants.Direction.DOWN},
				{"pos": Vector2i(8, 0), "value": 1, "dir": Constants.Direction.DOWN},
				{"pos": Vector2i(5, 6), "value": 2, "dir": Constants.Direction.UP},
				{"pos": Vector2i(8, 6), "value": 3, "dir": Constants.Direction.UP},
				{"pos": Vector2i(11, 1), "value": 1, "dir": Constants.Direction.LEFT},
				{"pos": Vector2i(11, 5), "value": 2, "dir": Constants.Direction.LEFT},
			],
			"targets": [
				{"pos": Vector2i(9, 3), "value": 300},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
				Constants.ToolMode.OPERATOR_MUL,
			],
			"hint": "2+3=5. Ara: 5×5=25, 2×2=4, 25×4=100, 100×3=300.",
		},
		# --- 4. Noranta-set (primer!) ---
		{
			"title": "97",
			"description": "97 és primer. No el pots factoritzar!\nCal construir un nombre proper i ajustar.",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 0), "value": 2, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 2), "value": 3, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 4), "value": 2, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 6), "value": 3, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(5, 0), "value": 1, "dir": Constants.Direction.DOWN},
				{"pos": Vector2i(8, 0), "value": 2, "dir": Constants.Direction.DOWN},
				{"pos": Vector2i(5, 6), "value": 1, "dir": Constants.Direction.UP},
				{"pos": Vector2i(8, 6), "value": 3, "dir": Constants.Direction.UP},
				{"pos": Vector2i(11, 1), "value": 1, "dir": Constants.Direction.LEFT},
				{"pos": Vector2i(11, 5), "value": 2, "dir": Constants.Direction.LEFT},
			],
			"targets": [
				{"pos": Vector2i(9, 3), "value": 97},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
				Constants.ToolMode.OPERATOR_SUB,
				Constants.ToolMode.OPERATOR_MUL,
			],
			"hint": "2+3=5, 2×2=4... 100-3=97. Com fas 100? 4×25=100, 25=5×5.",
		},
		# --- 5. Mil dues-centes noranta-sis ---
		{
			"title": "1296",
			"description": "1296 = 6⁴. Quadrat d'un quadrat!",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 0), "value": 2, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 2), "value": 3, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 4), "value": 2, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 6), "value": 3, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(4, 0), "value": 2, "dir": Constants.Direction.DOWN},
				{"pos": Vector2i(7, 0), "value": 3, "dir": Constants.Direction.DOWN},
				{"pos": Vector2i(4, 6), "value": 2, "dir": Constants.Direction.UP},
				{"pos": Vector2i(7, 6), "value": 3, "dir": Constants.Direction.UP},
			],
			"targets": [
				{"pos": Vector2i(11, 3), "value": 1296},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_MUL,
			],
			"hint": "2×3=6, 6×6=36, 36×36=1296. Quatre multiplicadors!",
		},
		# --- 6. Dos mil vint-i-cinc ---
		{
			"title": "2025",
			"description": "2025 = 45². Però 45 = 9 × 5 = 3² × 5.\nArbre de tres nivells!",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 0), "value": 3, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 2), "value": 2, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 4), "value": 3, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 6), "value": 2, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(4, 0), "value": 3, "dir": Constants.Direction.DOWN},
				{"pos": Vector2i(7, 0), "value": 1, "dir": Constants.Direction.DOWN},
				{"pos": Vector2i(4, 6), "value": 3, "dir": Constants.Direction.UP},
				{"pos": Vector2i(7, 6), "value": 2, "dir": Constants.Direction.UP},
				{"pos": Vector2i(10, 0), "value": 2, "dir": Constants.Direction.DOWN},
				{"pos": Vector2i(10, 6), "value": 3, "dir": Constants.Direction.UP},
			],
			"targets": [
				{"pos": Vector2i(11, 3), "value": 2025},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
				Constants.ToolMode.OPERATOR_MUL,
			],
			"hint": "3×3=9, 2+3=5, 9×5=45, 45×45=2025.",
		},
	]
