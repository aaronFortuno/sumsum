class_name Levels

static func get_all() -> Array[Dictionary]:
	return [
		{
			"title": "Suma bàsica",
			"description": "Connecta les fonts al sumador per obtenir 8.\nCol·loca cintes i un operador +.",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 2), "value": 5, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 4), "value": 3, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(11, 3), "value": 8},
			],
			"fixed_operators": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
			],
		},
		{
			"title": "Resta",
			"description": "Utilitza la resta per obtenir el resultat correcte.",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 2), "value": 10, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 4), "value": 4, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(11, 3), "value": 6},
			],
			"fixed_operators": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_SUB,
			],
		},
		{
			"title": "Multiplicació",
			"description": "Multiplica els dos nombres per arribar al destí.",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 2), "value": 6, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 4), "value": 7, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(11, 3), "value": 42},
			],
			"fixed_operators": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_MUL,
			],
		},
		{
			"title": "Operacions combinades",
			"description": "Utilitza suma i multiplicació per obtenir 26.\nPista: (2 + 11) × 2 = 26",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 1), "value": 2, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 3), "value": 11, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 5), "value": 2, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(11, 3), "value": 26},
			],
			"fixed_operators": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
				Constants.ToolMode.OPERATOR_MUL,
			],
		},
	]
