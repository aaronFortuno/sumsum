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
		{
			"title": "72",
			"description": "72 = 2³ × 3² = 8 × 9.",
			"grid_size": Vector2i(30, 20),
			"extractors": {2: 1.0, 3: 1.0},
			"targets": [{"pos": Vector2i(15, 10), "value": 72}],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_MUL,
			],
			"hint": "2×2×2=8, 3×3=9, 8×9=72.",
		},
		{
			"title": "300",
			"description": "300 = 2² × 3 × 5².\nNo tens 5... construeix-lo!",
			"grid_size": Vector2i(40, 25),
			"extractors": {1: 0.4, 2: 0.8, 3: 0.8},
			"targets": [{"pos": Vector2i(20, 12), "value": 300}],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
				Constants.ToolMode.OPERATOR_MUL,
			],
			"hint": "2+3=5, 5×5=25, 2×2=4, 25×4=100, 100×3=300.",
		},
		{
			"title": "97",
			"description": "97 és primer! 100 − 3 = 97.",
			"grid_size": Vector2i(40, 25),
			"extractors": {1: 0.4, 2: 0.8, 3: 0.8},
			"targets": [{"pos": Vector2i(20, 12), "value": 97}],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
				Constants.ToolMode.OPERATOR_SUB,
				Constants.ToolMode.OPERATOR_MUL,
			],
			"hint": "2+3=5, 5×5=25, 25×2×2=100, 100−3=97.",
		},
		{
			"title": "1296",
			"description": "1296 = 6⁴. Quadrat d'un quadrat!",
			"grid_size": Vector2i(30, 20),
			"extractors": {2: 1.0, 3: 1.0},
			"targets": [{"pos": Vector2i(15, 10), "value": 1296}],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_MUL,
			],
			"hint": "2×3=6, 6×6=36, 36×36=1296.",
		},
		{
			"title": "2025",
			"description": "2025 = 45² = (9×5)².",
			"grid_size": Vector2i(40, 30),
			"extractors": {1: 0.3, 2: 0.6, 3: 0.8},
			"targets": [{"pos": Vector2i(20, 15), "value": 2025}],
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
