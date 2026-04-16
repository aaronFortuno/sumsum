class_name PackExtractors2

static func get_pack() -> Dictionary:
	return {
		"id": "extractors_2",
		"title": "Extractor ×2",
		"description": "Ara tens extractors d'1 i de 2. Tot va més ràpid!",
		"difficulty": Packs.Difficulty.HARD,
		"target_age": [12, 15],
		"color": Color(0.3, 0.5, 0.9),
		"levels": _get_levels(),
	}

static func _get_levels() -> Array[Dictionary]:
	return [
		# --- 1. Seixanta-quatre ---
		{
			"title": "Seixanta-quatre",
			"description": "64 = 2⁶. Cadena de duplicació!",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 0), "value": 2, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 2), "value": 2, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 4), "value": 2, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 6), "value": 2, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(4, 0), "value": 2, "dir": Constants.Direction.DOWN},
				{"pos": Vector2i(7, 0), "value": 2, "dir": Constants.Direction.DOWN},
				{"pos": Vector2i(4, 6), "value": 1, "dir": Constants.Direction.UP},
				{"pos": Vector2i(7, 6), "value": 1, "dir": Constants.Direction.UP},
				{"pos": Vector2i(10, 0), "value": 1, "dir": Constants.Direction.DOWN},
				{"pos": Vector2i(10, 6), "value": 1, "dir": Constants.Direction.UP},
			],
			"targets": [
				{"pos": Vector2i(11, 3), "value": 64},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
				Constants.ToolMode.OPERATOR_MUL,
			],
			"hint": "2×2=4, 4×2=8, 8×2=16, 16×2=32, 32×2=64. Cadena!",
		},
		# --- 2. Cent ---
		{
			"title": "Cent",
			"description": "Construeix 100. Potències de 10?",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 0), "value": 2, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 2), "value": 1, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 4), "value": 2, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 6), "value": 1, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(5, 0), "value": 2, "dir": Constants.Direction.DOWN},
				{"pos": Vector2i(8, 0), "value": 1, "dir": Constants.Direction.DOWN},
				{"pos": Vector2i(5, 6), "value": 2, "dir": Constants.Direction.UP},
				{"pos": Vector2i(8, 6), "value": 1, "dir": Constants.Direction.UP},
				{"pos": Vector2i(11, 1), "value": 1, "dir": Constants.Direction.LEFT},
				{"pos": Vector2i(11, 5), "value": 2, "dir": Constants.Direction.LEFT},
			],
			"targets": [
				{"pos": Vector2i(9, 3), "value": 100},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
				Constants.ToolMode.OPERATOR_MUL,
			],
			"hint": "2+1=3... no. 2×2=4, 4+1=5, 5×... O: 2×2×... 4×25=100. 25=5×5, 5=2+1+2.",
		},
		# --- 3. Dos-cents cinquanta-sis ---
		{
			"title": "256",
			"description": "2⁸ = 256. La cadena més llarga!",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 0), "value": 2, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 2), "value": 2, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 4), "value": 2, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 6), "value": 2, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(3, 0), "value": 2, "dir": Constants.Direction.DOWN},
				{"pos": Vector2i(6, 0), "value": 2, "dir": Constants.Direction.DOWN},
				{"pos": Vector2i(9, 0), "value": 2, "dir": Constants.Direction.DOWN},
				{"pos": Vector2i(3, 6), "value": 2, "dir": Constants.Direction.UP},
				{"pos": Vector2i(6, 6), "value": 2, "dir": Constants.Direction.UP},
				{"pos": Vector2i(9, 6), "value": 2, "dir": Constants.Direction.UP},
			],
			"targets": [
				{"pos": Vector2i(11, 3), "value": 256},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_MUL,
			],
			"hint": "2→4→8→16→32→64→128→256. Set multiplicadors.",
		},
		# --- 4. Quaranta-vuit ---
		{
			"title": "Quaranta-vuit",
			"description": "48 = 2⁴ × 3. Construeix un 3 amb 2+1!",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 0), "value": 2, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 2), "value": 1, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 4), "value": 2, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 6), "value": 2, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(5, 0), "value": 1, "dir": Constants.Direction.DOWN},
				{"pos": Vector2i(8, 0), "value": 2, "dir": Constants.Direction.DOWN},
				{"pos": Vector2i(5, 6), "value": 1, "dir": Constants.Direction.UP},
				{"pos": Vector2i(8, 6), "value": 2, "dir": Constants.Direction.UP},
			],
			"targets": [
				{"pos": Vector2i(11, 3), "value": 48},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
				Constants.ToolMode.OPERATOR_MUL,
			],
			"hint": "2+1=3, 2×2=4, 4×2=8, 8×2=16, 16×3=48.",
		},
		# --- 5. Cent vint-i-set (primer de Mersenne!) ---
		{
			"title": "127",
			"description": "127 és primer! No el pots factoritzar.\nPero 128 − 1 = 127...",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 0), "value": 2, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 2), "value": 2, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 4), "value": 2, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 6), "value": 2, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(4, 0), "value": 2, "dir": Constants.Direction.DOWN},
				{"pos": Vector2i(7, 0), "value": 2, "dir": Constants.Direction.DOWN},
				{"pos": Vector2i(4, 6), "value": 1, "dir": Constants.Direction.UP},
				{"pos": Vector2i(7, 6), "value": 2, "dir": Constants.Direction.UP},
				{"pos": Vector2i(10, 0), "value": 2, "dir": Constants.Direction.DOWN},
				{"pos": Vector2i(10, 6), "value": 1, "dir": Constants.Direction.UP},
			],
			"targets": [
				{"pos": Vector2i(11, 3), "value": 127},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
				Constants.ToolMode.OPERATOR_SUB,
				Constants.ToolMode.OPERATOR_MUL,
			],
			"hint": "2⁷ = 128. 128 − 1 = 127. Cadena de ×2 i un − al final!",
		},
		# --- 6. Mil ---
		{
			"title": "Mil",
			"description": "1000 = 10³ = 8 × 125. Vols potències de 10 o de 2?",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 0), "value": 2, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 2), "value": 1, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 4), "value": 2, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 6), "value": 1, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(4, 0), "value": 2, "dir": Constants.Direction.DOWN},
				{"pos": Vector2i(7, 0), "value": 1, "dir": Constants.Direction.DOWN},
				{"pos": Vector2i(4, 6), "value": 2, "dir": Constants.Direction.UP},
				{"pos": Vector2i(7, 6), "value": 1, "dir": Constants.Direction.UP},
				{"pos": Vector2i(10, 0), "value": 2, "dir": Constants.Direction.DOWN},
				{"pos": Vector2i(10, 6), "value": 2, "dir": Constants.Direction.UP},
			],
			"targets": [
				{"pos": Vector2i(11, 3), "value": 1000},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
				Constants.ToolMode.OPERATOR_MUL,
			],
			"hint": "2+1=3... no. 2×2×2=8, 2+1+2=5, 5×5×5=125, 8×125=1000.",
		},
	]
