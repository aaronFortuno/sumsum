class_name PackMultiplication

static func get_pack() -> Dictionary:
	return {
		"id": "multiplication",
		"title": "Multiplicar",
		"description": "Taules de multiplicar, dobles, triples i quadrats.",
		"difficulty": Packs.Difficulty.MEDIUM,
		"target_age": [11, 13],
		"color": Color(0.6, 0.4, 0.9),
		"levels": _get_levels(),
	}

static func _get_levels() -> Array[Dictionary]:
	return [
		# --- 1. Taules de multiplicar ---
		{
			"title": "Taules de multiplicar",
			"description": "L'operador × multiplica dos nombres.\n6 × 7 = ?",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 2), "value": 6, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 4), "value": 7, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(11, 3), "value": 42},
			],
			"fixed_operators": [
				{"pos": Vector2i(5, 3), "op": Constants.OperatorType.MULTIPLY, "dir": Constants.Direction.RIGHT},
			],
			"fixed_conveyors": [],
			"available_tools": [Constants.ToolMode.CONVEYOR],
			"hint": "Porta el 6 i el 7 fins al multiplicador ×.",
		},
		# --- 2. Multiplica tu ---
		{
			"title": "Multiplica tu",
			"description": "Ara col·loca tu el multiplicador.\n8 × 5 = ?",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 2), "value": 8, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 4), "value": 5, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(11, 3), "value": 40},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_MUL,
			],
			"hint": "Col·loca un × entre les fonts i connecta-ho tot.",
		},
		# --- 3. Doble i triple ---
		{
			"title": "Doble i triple",
			"description": "Multiplica per 2 i per 3.\nEl doble i el triple de 5.",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 3), "value": 5, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(5, 0), "value": 2, "dir": Constants.Direction.DOWN},
				{"pos": Vector2i(5, 6), "value": 3, "dir": Constants.Direction.UP},
			],
			"targets": [
				{"pos": Vector2i(11, 1), "value": 10},
				{"pos": Vector2i(11, 5), "value": 15},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_MUL,
			],
			"hint": "Necessites dos multiplicadors: un per al doble i un per al triple.",
		},
		# --- 4. Suma i multiplica ---
		{
			"title": "Suma i multiplica",
			"description": "L'ordre importa!\n(2 + 3) × 4 = ?",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 1), "value": 2, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 3), "value": 3, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 5), "value": 4, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(11, 3), "value": 20},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
				Constants.ToolMode.OPERATOR_MUL,
			],
			"hint": "Primer suma 2+3=5, després multiplica 5×4=20.",
		},
		# --- 5. Quadrats ---
		{
			"title": "Quadrats",
			"description": "Un nombre multiplicat per si mateix!\n9 × 9 = ?",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 2), "value": 9, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 4), "value": 9, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(11, 3), "value": 81},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_MUL,
			],
			"hint": "Porta els dos 9 al multiplicador.",
		},
	]
