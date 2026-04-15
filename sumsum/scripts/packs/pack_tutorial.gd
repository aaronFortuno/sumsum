class_name PackTutorial

static func get_pack() -> Dictionary:
	return {
		"id": "tutorial",
		"title": "Primers passos",
		"description": "Aprèn a fer servir les cintes i els operadors.",
		"difficulty": Packs.Difficulty.TUTORIAL,
		"target_age": [10, 12],
		"color": Color(0.3, 0.8, 0.5),
		"levels": _get_levels(),
	}

static func _get_levels() -> Array[Dictionary]:
	return [
		# --- 1. La cinta transportadora ---
		{
			"title": "La cinta transportadora",
			"description": "Les fonts emeten boles amb nombres.\nCol·loca una cinta per connectar la font al destí.",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 3), "value": 5, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(3, 3), "value": 5},
			],
			"fixed_operators": [],
			"fixed_conveyors": [
				{"pos": Vector2i(1, 3), "dir": Constants.Direction.RIGHT},
			],
			"available_tools": [Constants.ToolMode.CONVEYOR],
			"hint": "Fes clic a la casella buida entre la font i el destí.",
		},
		# --- 2. Canviar de direcció ---
		{
			"title": "Canviar de direcció",
			"description": "Les cintes poden girar!\nArrossega per crear un camí fins al destí.",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 1), "value": 7, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(3, 4), "value": 7},
			],
			"fixed_operators": [],
			"fixed_conveyors": [
				{"pos": Vector2i(1, 1), "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(2, 1), "dir": Constants.Direction.RIGHT},
			],
			"available_tools": [Constants.ToolMode.CONVEYOR],
			"hint": "Arrossega des de la casella (3,1) cap avall.",
		},
		# --- 3. El sumador ---
		{
			"title": "El sumador",
			"description": "L'operador + suma dos nombres.\nConnecta les dues fonts al sumador.",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 2), "value": 3, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 4), "value": 2, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(7, 3), "value": 5},
			],
			"fixed_operators": [
				{"pos": Vector2i(5, 3), "op": Constants.OperatorType.ADD, "dir": Constants.Direction.RIGHT},
			],
			"fixed_conveyors": [
				{"pos": Vector2i(6, 3), "dir": Constants.Direction.RIGHT},
			],
			"available_tools": [Constants.ToolMode.CONVEYOR],
			"hint": "Porta el 3 per dalt i el 2 per baix fins al sumador +.",
		},
		# --- 4. Tot junt ---
		{
			"title": "Tot junt",
			"description": "Ara construeix tot el camí tu!\nConnecta les fonts al sumador i el sumador al destí.",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 1), "value": 4, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 5), "value": 6, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(9, 3), "value": 10},
			],
			"fixed_operators": [
				{"pos": Vector2i(6, 3), "op": Constants.OperatorType.ADD, "dir": Constants.Direction.RIGHT},
			],
			"fixed_conveyors": [],
			"available_tools": [Constants.ToolMode.CONVEYOR],
			"hint": "Porta les dues boles al +, i després el resultat al destí.",
		},
	]
