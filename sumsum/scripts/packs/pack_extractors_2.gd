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
		{
			"title": "Cent",
			"description": "Construeix 100.",
			"grid_size": Vector2i(30, 20),
			"extractors": {1: 0.8, 2: 1.0},
			"targets": [{"pos": Vector2i(15, 10), "value": 100}],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
				Constants.ToolMode.OPERATOR_MUL,
			],
			"hint": "2+2+1=5, 5×5=25, 2×2=4, 25×4=100.",
		},
		{
			"title": "256",
			"description": "2⁸ = 256.",
			"grid_size": Vector2i(40, 25),
			"extractors": {2: 1.2},
			"targets": [{"pos": Vector2i(20, 12), "value": 256}],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_MUL,
			],
			"hint": "2×2=4, 4×4=16, 16×16=256.",
		},
		{
			"title": "127",
			"description": "127 és primer! 128 − 1 = 127.",
			"grid_size": Vector2i(40, 25),
			"extractors": {1: 0.5, 2: 1.0},
			"targets": [{"pos": Vector2i(20, 12), "value": 127}],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
				Constants.ToolMode.OPERATOR_SUB,
				Constants.ToolMode.OPERATOR_MUL,
			],
			"hint": "2⁷ = 128. 128−1 = 127.",
		},
		{
			"title": "Mil",
			"description": "1000 = 8 × 125 = 2³ × 5³.",
			"grid_size": Vector2i(40, 30),
			"extractors": {1: 0.6, 2: 1.0},
			"targets": [{"pos": Vector2i(20, 15), "value": 1000}],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
				Constants.ToolMode.OPERATOR_MUL,
			],
			"hint": "2×2×2=8, 2+2+1=5, 5×5×5=125, 8×125=1000.",
		},
	]
