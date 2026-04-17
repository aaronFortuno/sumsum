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

# Density format: {value: extractors_per_100_cells}
# 1.0 = one extractor per 10×10 chunk on average

static func _get_levels() -> Array[Dictionary]:
	return [
		{
			"title": "Quatre",
			"description": "Construeix el 4 a partir d'uns.",
			"grid_size": Vector2i(30, 20),
			"extractors": {1: 1.5},
			"targets": [{"pos": Vector2i(15, 10), "value": 4}],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
				Constants.ToolMode.OPERATOR_MUL,
			],
			"hint": "1+1=2, 2×2=4.",
		},
		{
			"title": "Vuit",
			"description": "Construeix 8 = 2³.",
			"grid_size": Vector2i(30, 20),
			"extractors": {1: 1.5},
			"targets": [{"pos": Vector2i(15, 10), "value": 8}],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
				Constants.ToolMode.OPERATOR_MUL,
			],
			"hint": "1+1=2, 2×2=4, 4×2=8.",
		},
		{
			"title": "Setze",
			"description": "16 = 2⁴ = 4².",
			"grid_size": Vector2i(30, 20),
			"extractors": {1: 1.5},
			"targets": [{"pos": Vector2i(15, 10), "value": 16}],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
				Constants.ToolMode.OPERATOR_MUL,
			],
			"hint": "1+1=2, 2×2=4, 4×4=16.",
		},
		{
			"title": "Vint-i-cinc",
			"description": "25 = 5². Primer construeix un 5!",
			"grid_size": Vector2i(30, 20),
			"extractors": {1: 1.5},
			"targets": [{"pos": Vector2i(15, 10), "value": 25}],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
				Constants.ToolMode.OPERATOR_MUL,
			],
			"hint": "1+1=2, 2+1=3, 2+3=5, 5×5=25.",
		},
		{
			"title": "Trenta-sis",
			"description": "36 = 6².",
			"grid_size": Vector2i(30, 20),
			"extractors": {1: 1.5},
			"targets": [{"pos": Vector2i(15, 10), "value": 36}],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
				Constants.ToolMode.OPERATOR_MUL,
			],
			"hint": "1+1=2, 2+1=3, 2×3=6, 6×6=36.",
		},
		{
			"title": "Seixanta-quatre",
			"description": "64 = 2⁶.",
			"grid_size": Vector2i(40, 25),
			"extractors": {1: 1.2},
			"targets": [{"pos": Vector2i(20, 12), "value": 64}],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
				Constants.ToolMode.OPERATOR_MUL,
			],
			"hint": "1+1=2, 2×2=4, 4×4=16, 16×4=64.",
		},
	]
