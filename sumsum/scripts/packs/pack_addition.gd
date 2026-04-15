class_name PackAddition

static func get_pack() -> Dictionary:
	return {
		"id": "addition",
		"title": "Sumar",
		"description": "Domina la suma col·locant operadors i cintes.",
		"difficulty": Packs.Difficulty.EASY,
		"target_age": [10, 12],
		"color": Color(0.3, 0.7, 0.9),
		"levels": _get_levels(),
	}

static func _get_levels() -> Array[Dictionary]:
	return [
		# --- 1. Suma simple ---
		{
			"title": "Suma simple",
			"description": "Col·loca un sumador (+) i connecta les fonts.\n3 + 5 = ?",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 2), "value": 3, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 4), "value": 5, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(11, 3), "value": 8},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
			],
			"hint": "Col·loca el + entre les dues fonts i apunta'l cap a la dreta.",
		},
		# --- 2. Suma amb tres nombres ---
		{
			"title": "Suma amb tres nombres",
			"description": "Un operador pot rebre més de dues entrades.\n2 + 3 + 4 = ?",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 1), "value": 2, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 3), "value": 3, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 5), "value": 4, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(11, 3), "value": 9},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
			],
			"hint": "Porta els tres nombres al mateix sumador.",
		},
		# --- 3. Dos destins ---
		{
			"title": "Dos destins",
			"description": "Dos destins, dues sumes!\nUtilitza les fonts per alimentar dos sumadors.",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 1), "value": 4, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 3), "value": 3, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 5), "value": 6, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(11, 1), "value": 7},
				{"pos": Vector2i(11, 5), "value": 9},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
			],
			"hint": "Cada destí necessita el seu propi sumador.",
		},
		# --- 4. Suma en cadena ---
		{
			"title": "Suma en cadena",
			"description": "Encadena dos sumadors!\nEl resultat d'un pot entrar a un altre.",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 2), "value": 2, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 4), "value": 3, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(6, 0), "value": 4, "dir": Constants.Direction.DOWN},
			],
			"targets": [
				{"pos": Vector2i(11, 3), "value": 9},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
			],
			"hint": "Suma primer 2+3, després suma-hi el 4.",
		},
		# --- 5. El gran sumador ---
		{
			"title": "El gran sumador",
			"description": "Nombres més grans!\n15 + 27 = ?",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 2), "value": 15, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 4), "value": 27, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(11, 3), "value": 42},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
			],
			"hint": "És una suma directa. On col·loques el +?",
		},
	]
