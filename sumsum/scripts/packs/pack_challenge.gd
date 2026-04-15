class_name PackChallenge

static func get_pack() -> Dictionary:
	return {
		"id": "challenge",
		"title": "Repte",
		"description": "Puzzles de routing complex amb matemàtiques avançades.",
		"difficulty": Packs.Difficulty.HARD,
		"target_age": [13, 15],
		"color": Color(0.9, 0.3, 0.4),
		"levels": _get_levels(),
	}

static func _get_levels() -> Array[Dictionary]:
	return [
		# --- 1. Laberint ---
		{
			"title": "Laberint",
			"description": "Les fonts vénen de tots costats!\n7 + 3 + 5 = ?",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 3), "value": 7, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(11, 1), "value": 3, "dir": Constants.Direction.LEFT},
				{"pos": Vector2i(6, 0), "value": 5, "dir": Constants.Direction.DOWN},
			],
			"targets": [
				{"pos": Vector2i(6, 6), "value": 15},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
			],
			"hint": "Porta les tres boles a un sumador al centre de la graella.",
		},
		# --- 2. Cadena llarga ---
		{
			"title": "Cadena llarga",
			"description": "Quatre operacions en cadena!\n((1 + 2) × 3 − 1) ÷ 2 = ?",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 0), "value": 1, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 2), "value": 2, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 4), "value": 3, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(4, 6), "value": 1, "dir": Constants.Direction.UP},
				{"pos": Vector2i(8, 0), "value": 2, "dir": Constants.Direction.DOWN},
			],
			"targets": [
				{"pos": Vector2i(11, 3), "value": 4},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
				Constants.ToolMode.OPERATOR_SUB,
				Constants.ToolMode.OPERATOR_MUL,
				Constants.ToolMode.OPERATOR_DIV,
			],
			"hint": "1+2=3, 3×3=9, 9−1=8, 8÷2=4.",
		},
		# --- 3. Paral·lel ---
		{
			"title": "Paral·lel",
			"description": "Dues fàbriques en paral·lel!\n6 × 2 = ? i 10 − 3 = ?",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 0), "value": 6, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 2), "value": 2, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 4), "value": 10, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 6), "value": 3, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(11, 1), "value": 12},
				{"pos": Vector2i(11, 5), "value": 7},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_MUL,
				Constants.ToolMode.OPERATOR_SUB,
			],
			"hint": "6×2=12 a dalt, 10−3=7 a baix.",
		},
		# --- 4. Convergència ---
		{
			"title": "Convergència",
			"description": "Dues cadenes que es troben.\n(2 + 5) × (8 − 3) = ?",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 0), "value": 2, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 2), "value": 5, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 4), "value": 8, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 6), "value": 3, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(11, 3), "value": 35},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
				Constants.ToolMode.OPERATOR_SUB,
				Constants.ToolMode.OPERATOR_MUL,
			],
			"hint": "2+5=7, 8−3=5, 7×5=35.",
		},
		# --- 5. Encreuament ---
		{
			"title": "Encreuament",
			"description": "Les cintes es creuen!\n4+7=? i 7−2=?",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 0), "value": 4, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 2), "value": 3, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 4), "value": 7, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 6), "value": 2, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(11, 1), "value": 11},
				{"pos": Vector2i(11, 5), "value": 5},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
				Constants.ToolMode.OPERATOR_SUB,
			],
			"hint": "4+7=11 i 7−2=5. La font 3 no cal!",
		},
		# --- 6. Economia ---
		{
			"title": "Economia",
			"description": "Moltes fonts, eines limitades!\nAconsegueix 13.",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 0), "value": 5, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 2), "value": 3, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 3), "value": 8, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 5), "value": 2, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 6), "value": 4, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(11, 3), "value": 13},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
				Constants.ToolMode.OPERATOR_MUL,
			],
			"tool_limits": {
				Constants.ToolMode.OPERATOR_ADD: 1,
				Constants.ToolMode.OPERATOR_MUL: 1,
			},
			"hint": "5+8=13. El × no cal!",
		},
		# --- 7. Triple objectiu ---
		{
			"title": "Triple objectiu",
			"description": "3 objectius amb 4 fonts!\nObjectius: 10, 24 i 3.",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 0), "value": 6, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 2), "value": 4, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 4), "value": 2, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 6), "value": 5, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(11, 0), "value": 10},
				{"pos": Vector2i(11, 3), "value": 24},
				{"pos": Vector2i(11, 6), "value": 3},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
				Constants.ToolMode.OPERATOR_MUL,
				Constants.ToolMode.OPERATOR_DIV,
			],
			"hint": "6+4=10, 6×4=24, 6÷2=3. Font 5 no cal!",
		},
		# --- 8. El mestre ---
		{
			"title": "El mestre",
			"description": "Fonts sobrants i recursos limitats!\nObjectius: 35 i 4.",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 0), "value": 2, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 2), "value": 3, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 4), "value": 5, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 6), "value": 7, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(11, 1), "value": 35},
				{"pos": Vector2i(11, 5), "value": 4},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_MUL,
				Constants.ToolMode.OPERATOR_SUB,
			],
			"tool_limits": {
				Constants.ToolMode.OPERATOR_MUL: 1,
				Constants.ToolMode.OPERATOR_SUB: 1,
			},
			"hint": "5×7=35, 7−3=4. Font 2 no cal!",
		},
	]
