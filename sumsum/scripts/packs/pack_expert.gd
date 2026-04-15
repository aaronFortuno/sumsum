class_name PackExpert

static func get_pack() -> Dictionary:
	return {
		"id": "expert",
		"title": "Expert",
		"description": "Reptes avançats: decimals, múltiples destins i arbres d'operacions.",
		"difficulty": Packs.Difficulty.EXPERT,
		"target_age": [14, 16],
		"color": Color(0.8, 0.2, 0.6),
		"levels": _get_levels(),
	}

static func _get_levels() -> Array[Dictionary]:
	return [
		# --- 1. Decimals ---
		{
			"title": "Decimals",
			"description": "Les divisions poden donar decimals!\n7 ÷ 2 + 1.5 = ?",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 1), "value": 7, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 3), "value": 2, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 5), "value": 1.5, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(11, 3), "value": 5},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
				Constants.ToolMode.OPERATOR_DIV,
			],
			"hint": "7÷2=3.5, 3.5+1.5=5.",
		},
		# --- 2. Quatre destins ---
		{
			"title": "Quatre destins",
			"description": "La mateixa parella, les quatre operacions!\n20 ? 5 = 25, 15, 100, 4",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 2), "value": 20, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 4), "value": 5, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(11, 0), "value": 25},
				{"pos": Vector2i(11, 2), "value": 15},
				{"pos": Vector2i(11, 4), "value": 100},
				{"pos": Vector2i(11, 6), "value": 4},
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
			"hint": "20+5=25, 20−5=15, 20×5=100, 20÷5=4.",
		},
		# --- 3. Piràmide ---
		{
			"title": "Piràmide",
			"description": "Una piràmide d'operacions!\n(2 × 3) + (5 × 4) = ?",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 0), "value": 2, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 2), "value": 3, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 4), "value": 5, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 6), "value": 4, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(11, 3), "value": 26},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
				Constants.ToolMode.OPERATOR_MUL,
			],
			"hint": "2×3=6, 5×4=20, 6+20=26.",
		},
		# --- 4. El gran final ---
		{
			"title": "El gran final",
			"description": "El repte definitiu!\nDues cadenes complexes amb cinc fonts.",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 0), "value": 10, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 2), "value": 3, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 4), "value": 4, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 6), "value": 2, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(6, 0), "value": 5, "dir": Constants.Direction.DOWN},
			],
			"targets": [
				{"pos": Vector2i(11, 1), "value": 35},
				{"pos": Vector2i(11, 5), "value": 30},
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
			"hint": "(10−3)×5 = 35 i (4+2)×5 = 30.",
		},
		# --- 5. Negatiu útil ---
		{
			"title": "Negatiu útil",
			"description": "El resultat és negatiu!\nAconsegueix −7.",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 0), "value": 3, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 2), "value": 8, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 4), "value": 5, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 6), "value": 2, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(11, 3), "value": -7},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_ADD,
				Constants.ToolMode.OPERATOR_SUB,
			],
			"hint": "3−8−2=−7. Font 5 no cal!",
		},
		# --- 6. Fracció justa ---
		{
			"title": "Fracció justa",
			"description": "El resultat és decimal!\nAconsegueix 1.5.",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 1), "value": 7, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 3), "value": 3, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 5), "value": 2, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(11, 3), "value": 1.5},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_SUB,
				Constants.ToolMode.OPERATOR_DIV,
			],
			"hint": "3÷2=1.5. Font 7 no cal!",
		},
		# --- 7. Tres pisos ---
		{
			"title": "Tres pisos",
			"description": "Tres operacions encadenades!\n2 × 3 × 5 − 1 = ?",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 0), "value": 2, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 2), "value": 3, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 3), "value": 4, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 5), "value": 5, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 6), "value": 1, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(11, 3), "value": 29},
			],
			"fixed_operators": [],
			"fixed_conveyors": [],
			"available_tools": [
				Constants.ToolMode.CONVEYOR,
				Constants.ToolMode.OPERATOR_MUL,
				Constants.ToolMode.OPERATOR_SUB,
			],
			"tool_limits": {
				Constants.ToolMode.OPERATOR_MUL: 2,
				Constants.ToolMode.OPERATOR_SUB: 1,
			},
			"hint": "2×3=6, 6×5=30, 30−1=29. Font 4 no cal!",
		},
		# --- 8. L'últim repte ---
		{
			"title": "L'últim repte",
			"description": "El repte final!\n6 fonts, 2 objectius, 4 operadors limitats.",
			"grid_size": Vector2i(12, 7),
			"sources": [
				{"pos": Vector2i(0, 0), "value": 3, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 1), "value": 7, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 2), "value": 2, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 4), "value": 5, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 5), "value": 4, "dir": Constants.Direction.RIGHT},
				{"pos": Vector2i(0, 6), "value": 1, "dir": Constants.Direction.RIGHT},
			],
			"targets": [
				{"pos": Vector2i(11, 1), "value": 50},
				{"pos": Vector2i(11, 5), "value": 3},
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
			"tool_limits": {
				Constants.ToolMode.OPERATOR_ADD: 1,
				Constants.ToolMode.OPERATOR_SUB: 1,
				Constants.ToolMode.OPERATOR_MUL: 1,
				Constants.ToolMode.OPERATOR_DIV: 1,
			},
			"hint": "(3+7)×5=50 i 4−1=3. Fonts 2 no cal!",
		},
	]
